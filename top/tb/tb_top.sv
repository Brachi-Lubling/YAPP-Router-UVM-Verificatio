/*-----------------------------------------------------------------
File name     : top.sv
Description   : lab01_data top module template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/

`include "uvm_macros.svh"
import uvm_pkg::*;

import yapp_router_reg_pkg::*;
import yapp_pkg::*;
import hbus_pkg::*;
import channel_pkg::*;
import clock_and_reset_pkg::*;
import router_module_pkg::*;

`include "router_mcsequencer.sv"
`include "router_mcseqs_lib.sv"
`include "router_tb.sv"
`include "router_test_lib.sv"

module tb_top;

  initial begin
    yapp_vif_config::set(null, "uvm_test_top.tb.yapp.agent.*", "vif", hw_top.in0);

    clock_and_reset_vif_config::set(null, "uvm_test_top.tb.clock_and_reset.agent.*", "vif", hw_top.clock_and_reset);

    hbus_vif_config::set(null, "uvm_test_top.tb.hbus.*", "vif", hw_top.hbus);

    channel_vif_config::set(null, "uvm_test_top.tb.chan0.rx_agent.*", "vif", hw_top.chan0);
    channel_vif_config::set(null, "uvm_test_top.tb.chan1.rx_agent.*", "vif", hw_top.chan1);
    channel_vif_config::set(null, "uvm_test_top.tb.chan2.rx_agent.*", "vif", hw_top.chan2);

    run_test();
  end

endmodule
