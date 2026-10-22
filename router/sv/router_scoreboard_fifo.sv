
class router_scoreboard_fifo extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard_fifo)

    // Analysis FIFOs
    uvm_tlm_analysis_fifo #(yapp_packet)     yapp_fifo;
    uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo;
    uvm_tlm_analysis_fifo #(channel_packet)  chan0_fifo;
    uvm_tlm_analysis_fifo #(channel_packet)  chan1_fifo;
    uvm_tlm_analysis_fifo #(channel_packet)  chan2_fifo;

    // Get ports
    uvm_get_port #(yapp_packet)      yapp_get_port;
    uvm_get_port #(hbus_transaction) hbus_get_port;
    uvm_get_port #(channel_packet)   chan0_get_port;
    uvm_get_port #(channel_packet)   chan1_get_port;
    uvm_get_port #(channel_packet)   chan2_get_port;

    bit [5:0] maxpktsize = 6'h3F;
    bit router_en = 1'b1;

    int unsigned dropped_disabled = 0;
    int unsigned dropped_size = 0;
    int unsigned dropped_addr = 0;
    int unsigned packets_received = 0;
    int unsigned wrong_packets = 0;
    int unsigned matched_packets = 0;
    int unsigned fifo_items_remaining = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        yapp_get_port  = new("yapp_get_port", this);
        hbus_get_port  = new("hbus_get_port", this);
        chan0_get_port = new("chan0_get_port", this);
        chan1_get_port = new("chan1_get_port", this);
        chan2_get_port = new("chan2_get_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        yapp_fifo  = new("yapp_fifo", this);
        hbus_fifo  = new("hbus_fifo", this);
        chan0_fifo = new("chan0_fifo", this);
        chan1_fifo = new("chan1_fifo", this);
        chan2_fifo = new("chan2_fifo", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        chan0_get_port.connect(chan0_fifo.get_peek_export);
        chan1_get_port.connect(chan1_fifo.get_peek_export);
        chan2_get_port.connect(chan2_fifo.get_peek_export);
    endfunction

    function bit comp_equal(input yapp_packet yp,
                            input channel_packet cp);
        uvm_comparer comparer;
        bit result;

        super.connect_phase(phase);

        yapp_get_port.connect(yapp_fifo.get_peek_export);
        hbus_get_port.connect(hbus_fifo.get_peek_export);
        chan0_get_port.connect(chan0_fifo.get_peek_export);
        chan1_get_port.connect(chan1_fifo.get_peek_export);
        chan2_get_port.connect(chan2_fifo.get_peek_export);
    endfunction

    function bit comp_equal(input yapp_packet yp,
                            input channel_packet cp);
        uvm_comparer comparer;
        bit result;

        comparer = new();
        result = 1;

        result &= comparer.compare_field(
            "addr", yp.addr, cp.addr, $bits(yp.addr));

        result &= comparer.compare_field(
            "length", yp.length, cp.length, $bits(yp.length));

        foreach (yp.payload[i])
            result &= comparer.compare_field(
                $sformatf("payload[%0d]", i),
                yp.payload[i],
                cp.payload[i],
                $bits(yp.payload[i]));

        result &= comparer.compare_field(
            "parity", yp.parity, cp.parity, $bits(yp.parity));

        if (!result)
            `uvm_error("PKT_COMPARE",
                "YAPP packet and Channel packet mismatch")

        return result;
    endfunction

    virtual task run_phase(uvm_phase phase);
        fork
            process_hbus_transactions();
            process_yapp_packets();
        join
    endtask


    task process_yapp_packets();
        yapp_packet ypkt;
        channel_packet cpkt;

        forever begin
            yapp_get_port.get(ypkt);

            if (!router_en) begin
                dropped_disabled++;
                continue;
            end

            if (ypkt.length > maxpktsize) begin
                dropped_size++;
                continue;
            end

            if (ypkt.addr > 2) begin
                dropped_addr++;
                continue;
            end

            case (ypkt.addr)
                2'b00: chan0_get_port.get(cpkt);
                2'b01: chan1_get_port.get(cpkt);
                2'b10: chan2_get_port.get(cpkt);
                default: continue;
            endcase

            packets_received++;

            if (comp_equal(ypkt, cpkt))
                matched_packets++;
            else
                wrong_packets++;
        end
    endtask

 
    task process_hbus_transactions();
        hbus_transaction hpkt;

        forever begin
            hbus_get_port.get(hpkt);

            if (hpkt.hwr_rd != HBUS_WRITE)
                continue;

            case (hpkt.haddr)
                16'h1000: maxpktsize = hpkt.hdata[5:0];
                16'h1001: router_en = hpkt.hdata[0];
                default: ;
            endcase
        end
    endtask

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);

        fifo_items_remaining =
            yapp_fifo.used()  +
            hbus_fifo.used()  +
            chan0_fifo.used() +
            chan1_fifo.used() +
            chan2_fifo.used();

        `uvm_info("SCOREBOARD_FIFO_CHECK",
            $sformatf(
                "Remaining FIFO items: YAPP=%0d, HBUS=%0d, CH0=%0d, CH1=%0d, CH2=%0d",
                yapp_fifo.used(),
                hbus_fifo.used(),
                chan0_fifo.used(),
                chan1_fifo.used(),
                chan2_fifo.used()),
            UVM_LOW)

        if (fifo_items_remaining != 0)
            `uvm_error("SB_FIFO_REMAINING",
                $sformatf(
                    "FIFOs are not empty: %0d items remain",
                    fifo_items_remaining))
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("SCOREBOARD_REPORT",
            $sformatf(
                "Packets compared: %0d, Matched: %0d, Wrong: %0d",
                packets_received,
                matched_packets,
                wrong_packets),
            UVM_LOW)

        `uvm_info("SCOREBOARD_DROPPED",
            $sformatf(
                "Dropped - Router disabled: %0d, Size: %0d, Address: %0d",
                dropped_disabled,
                dropped_size,
                dropped_addr),
            UVM_LOW)

        `uvm_info("SCOREBOARD_FIFO_REPORT",
            $sformatf(
                "Total remaining FIFO items at check_phase: %0d",
                fifo_items_remaining),
            UVM_LOW)
    endfunction

endclass
