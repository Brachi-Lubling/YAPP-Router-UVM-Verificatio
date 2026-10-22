/*-----------------------------------------------------------------
File name     : yapp_packet.sv
Description   : lab01_data YAPP UVC packet template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

typedef enum bit {BAD_PARITY, GOOD_PARITY} parity_t;

class yapp_packet extends uvm_sequence_item;
  rand bit [5:0] length;
  rand bit [1:0] addr;
  rand bit [7:0] payload[];
  bit [7:0] parity;

  rand int packet_delay;
  rand parity_t parity_type;

  constraint payload_size { length == payload.size(); }
  constraint default_length { length > 0; length < 64; }
  constraint pkt_delay { packet_delay > 1; packet_delay < 20; }
  //constraint valid_addr { addr != 2'b11; }
  constraint parity_dist { 
    parity_type dist { GOOD_PARITY := 70, BAD_PARITY := 30 }; 
  }

  function new(string name = "yapp_packet");
    super.new(name);
  endfunction

  function bit [7:0] calc_parity();
    bit [7:0] calculated_parity;
    calculated_parity = {length, addr}; 

    foreach (payload[i]) begin
      calculated_parity = calculated_parity ^ payload[i];
    end
    return calculated_parity;
  endfunction

  function void set_parity();
    if (parity_type == GOOD_PARITY) begin
      parity = calc_parity();
    end else begin
      parity = ~calc_parity(); 
    end
  endfunction

  function void post_randomize();
    set_parity();
  endfunction

  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(length, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON)
    `uvm_field_enum(parity_t, parity_type, UVM_ALL_ON)
  `uvm_object_utils_end

endclass : yapp_packet

class short_yapp_packet extends yapp_packet;

  function new(string name = "yapp_packet");
    super.new(name);
  endfunction

  `uvm_object_utils(short_yapp_packet)

  constraint short_length { length < 15; } 
endclass : short_yapp_packet
