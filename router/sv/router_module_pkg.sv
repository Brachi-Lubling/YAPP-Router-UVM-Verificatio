`timescale 1ns/1ns

package router_module_pkg;
    import uvm_pkg::*;
    
    import yapp_pkg::*;
    import hbus_pkg::*;
    import channel_pkg::*;

    `include "uvm_macros.svh"

    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_hbus)
    `uvm_analysis_imp_decl(_chan0)
    `uvm_analysis_imp_decl(_chan1)
    `uvm_analysis_imp_decl(_chan2)

    `include "router_reference.sv"
    `include "router_scoreboard.sv"
    `include "router_scoreboard_fifo.sv"
    `include "router_module_env.sv"

endpackage : router_module_pkg