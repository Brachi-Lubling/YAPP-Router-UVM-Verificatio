class yapp_tx_monitor extends uvm_monitor;


    virtual interface yapp_if vif;
    
    yapp_packet pkt;
    int num_pkt_col;

    uvm_analysis_port #(yapp_packet) yapp_out;

    `uvm_component_utils(yapp_tx_monitor)

    covergroup yapp_packet_cg;

        packet_length_cp: coverpoint pkt.length {
            bins MIN    = {1};
            bins MAX    = {63};
            bins SMALL  = {[2:10]};
            bins MEDIUM = {[11:40]};
            bins LARGE  = {[41:62]};
        }
    
        packet_addr_cp: coverpoint pkt.addr {
            bins legal_addr[] = {[0:2]};
            bins illegal_addr = {3};
        }
    
        packet_parity_cp: coverpoint pkt.parity_type {
            bins good_parity = {GOOD_PARITY};
            bins bad_parity  = {BAD_PARITY};
        }
    
        length_addr_parity_cross:
            cross packet_length_cp, packet_addr_cp, packet_parity_cp {
                ignore_bins illegal_addr =
                    binsof(packet_addr_cp.illegal_addr);
    
                ignore_bins good_parity =
                    binsof(packet_parity_cp.good_parity);
            }
    
    endgroup : yapp_packet_cg
       
    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_out = new("yapp_out", this);
        yapp_packet_cg = new();
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if (!yapp_vif_config::get(this, "", "vif", vif))
            `uvm_error("NOVIF", "vif not set")
    endfunction

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "hi, Im in the monitor", UVM_LOW)
        @(posedge vif.reset);
        @(negedge vif.reset);
        `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
        forever begin 
          pkt = yapp_packet::type_id::create("pkt", this);

          fork
            vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
            @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
          join

          pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
          end_tr(pkt);

          yapp_packet_cg.sample();  

          `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
          yapp_out.write(pkt);
          num_pkt_col++;
        end
    endtask

    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "monitor starting simulation phase", UVM_LOW)
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction : report_phase

endclass