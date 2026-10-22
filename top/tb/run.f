/*-----------------------------------------------------------------
File name     : run.f
Description   : lab01_data simulator run template file
Notes         : From the Cadence "SystemVerilog Advanced Verification with UVM" training
              : Set $UVMHOME to install directory of UVM library
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2015
-----------------------------------------------------------------*/


// --- Basic flags ---
-64
-uvmhome $UVMHOME
-uvm
-timescale 1ns/1ns
-gui -access rwc
+UVM_TESTNAME=uvm_mem_walk_test
+UVM_VERBOSITY=UVM_FULL
+SVSEED=random
//-uvmnocdnsextra remove some uvm advanced features (helps some times...)

// --- Coverage ---
-coverage U

// --- Clock and Reset UVC ---
+incdir+../../clock_and_reset/sv
../../clock_and_reset/sv/clock_and_reset_pkg.sv
../../clock_and_reset/sv/clock_and_reset_if.sv

// --- YAPP UVC ---
+incdir+../../yapp/sv
../../yapp/sv/yapp_pkg.sv
../../yapp/sv/yapp_if.sv

// --- HBUS UVC ---
+incdir+../../hbus/sv
../../hbus/sv/hbus_pkg.sv
../../hbus/sv/hbus_if.sv

// --- Channel UVC ---
+incdir+../../channel/sv
../../channel/sv/channel_pkg.sv
../../channel/sv/channel_if.sv

// --- Router Module Package ---
+incdir+../../router/sv
../../router/sv/router_module_pkg.sv

// --- Registers Module ---
cdns_uvmreg_utils_pkg.sv
yapp_router_regs_rdb.sv

// --- Top, RTL & Testbench Files ---
clkgen.sv
hw_top.sv
tb_top.sv
../../router_rtl/yapp_router.sv
