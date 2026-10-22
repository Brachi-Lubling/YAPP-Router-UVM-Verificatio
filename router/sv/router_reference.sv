class router_reference extends uvm_component;

    `uvm_component_utils(router_reference)

    uvm_analysis_imp_yapp #(yapp_packet, router_reference) yapp_in;
    uvm_analysis_imp_hbus #(hbus_transaction, router_reference) hbus_in;
    uvm_analysis_port #(yapp_packet) valid_yapp_out;

    bit [5:0] maxpktsize = 6'h3F;
    bit router_en = 1'b1;

    int unsigned dropped_disabled = 0;
    int unsigned dropped_size = 0;
    int unsigned dropped_addr = 0;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        hbus_in = new("hbus_in", this);
        valid_yapp_out = new("valid_yapp_out", this);
    endfunction

    function void write_hbus(input hbus_transaction packet);

        if (packet.hwr_rd != HBUS_WRITE)
            return;

        case (packet.haddr)
            16'h1000: maxpktsize = packet.hdata[5:0];
            16'h1001: router_en = packet.hdata[0];
            default: ;
        endcase

    endfunction

    function void write_yapp(input yapp_packet packet);

        yapp_packet ypkt;
        $cast(ypkt, packet.clone());

        if (!router_en) begin
            dropped_disabled++;
        end
        else if (ypkt.length > maxpktsize) begin
            dropped_size++;
        end
        else if (ypkt.addr > 2) begin
            dropped_addr++;
        end
        else begin
            valid_yapp_out.write(ypkt);
        end

    endfunction

endclass : router_reference