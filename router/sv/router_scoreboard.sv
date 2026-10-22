class router_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(router_scoreboard)

    uvm_analysis_imp_yapp#(yapp_packet, router_scoreboard) yapp_in;
    uvm_analysis_imp_chan0#(channel_packet, router_scoreboard) chan0_in;
    uvm_analysis_imp_chan1#(channel_packet, router_scoreboard) chan1_in;
    uvm_analysis_imp_chan2#(channel_packet, router_scoreboard) chan2_in;

    yapp_packet queue0[$];
    yapp_packet queue1[$];
    yapp_packet queue2[$];

    int packets_received = 0;
    int wrong_packets = 0;
    int matched_packets = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        chan0_in = new("chan0_in", this);
        chan1_in = new("chan1_in", this);
        chan2_in = new("chan2_in", this);
    endfunction

    function bit comp_equal(input yapp_packet yp, input channel_packet cp);
        uvm_comparer comparer;
        bit result;
    
        comparer = new();
    
        result = 1;
    
        result &= comparer.compare_field("addr", yp.addr, cp.addr, $bits(yp.addr));
        result &= comparer.compare_field("length", yp.length, cp.length, $bits(yp.length));
    
        foreach (yp.payload[i])
            result &= comparer.compare_field(
                $sformatf("payload[%0d]", i),
                yp.payload[i], cp.payload[i], $bits(yp.payload[i])
            );
    
        result &= comparer.compare_field("parity", yp.parity, cp.parity, $bits(yp.parity));
    
        if (!result)
            `uvm_error("PKT_COMPARE", "YAPP packet and Channel packet mismatch")
    
        return result;
    endfunction

    function void write_yapp(input yapp_packet packet);

        yapp_packet ypkt;
        $cast( ypkt,  packet.clone() );
        case (ypkt.addr)
            2'b00:queue0.push_back(ypkt);
            2'b01:queue1.push_back(ypkt);
            2'b10:queue2.push_back(ypkt);
            default: `uvm_error("SB_ADDR", $sformatf("Invalid YAPP address: %0d", ypkt.addr))
        endcase
    endfunction

    function void write_chan0(input channel_packet packet);
        yapp_packet yp;

        if (queue0.size() == 0) begin
            wrong_packets++;
            `uvm_error("SB_EMPTY", "Received Channel 0 packet but queue0 is empty")
            return;
        end
    
        yp = queue0.pop_front();
    
        if (comp_equal(yp, packet))
            matched_packets++;
        else
            wrong_packets++;
    
        packets_received++;
    endfunction
    
    function void write_chan1(input channel_packet packet);
        yapp_packet yp;

        if (queue1.size() == 0) begin
            wrong_packets++;
            `uvm_error("SB_EMPTY", "Received Channel 1 packet but queue1 is empty")
            return;
        end
    
        yp = queue1.pop_front();
    
        if (comp_equal(yp, packet))
            matched_packets++;
        else
            wrong_packets++;
    
        packets_received++;
    endfunction   

    function void write_chan2(input channel_packet packet);
        yapp_packet yp;

        if (queue2.size() == 0) begin
            wrong_packets++;
            `uvm_error("SB_EMPTY", "Received Channel 2 packet but queue2 is empty")
            return;
        end
    
        yp = queue2.pop_front();
    
        if (comp_equal(yp, packet))
            matched_packets++;
        else
            wrong_packets++;
    
        packets_received++;
    endfunction

   virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info("SCOREBOARD_REPORT",
        $sformatf("Packets received: %0d, Wrong packets: %0d, Matched packets: %0d",
                  packets_received, wrong_packets, matched_packets),
        UVM_HIGH)

    `uvm_info("SCOREBOARD_QUEUES",
        $sformatf("Packets remaining in queues: queue0=%0d, queue1=%0d, queue2=%0d",
                  queue0.size(), queue1.size(), queue2.size()),
        UVM_HIGH)
endfunction

endclass