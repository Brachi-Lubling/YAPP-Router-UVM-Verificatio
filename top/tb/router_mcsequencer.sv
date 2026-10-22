class router_mcsequencer extends uvm_sequencer;

    `uvm_component_utils(router_mcsequencer)

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    yapp_tx_sequencer yapp_seqr;
    hbus_master_sequencer hbus_seqr;


endclass : router_mcsequencer