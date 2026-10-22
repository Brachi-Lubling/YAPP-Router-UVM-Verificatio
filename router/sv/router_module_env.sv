class router_module_env extends uvm_env;

    `uvm_component_utils(router_module_env)

    uvm_analysis_export #(yapp_packet) yapp_exprt;
    uvm_analysis_export #(hbus_transaction) hbus_exprt;
    uvm_analysis_export #(channel_packet) chan0_exprt;
    uvm_analysis_export #(channel_packet) chan1_exprt;
    uvm_analysis_export #(channel_packet) chan2_exprt;

    router_scoreboard scoreboard;
    router_reference reference_model;

    router_scoreboard_fifo scoreboard_fifo;

    function new(string name, uvm_component parent);
        super.new(name, parent);

        yapp_exprt = new("yapp_exprt", this);
        hbus_exprt = new("hbus_exprt", this);
        chan0_exprt = new("chan0_exprt", this);
        chan1_exprt = new("chan1_exprt", this);
        chan2_exprt = new("chan2_exprt", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        scoreboard = router_scoreboard::type_id::create("scoreboard", this);
        reference_model = router_reference::type_id::create("reference_model", this);
    
        scoreboard_fifo = router_scoreboard_fifo::type_id::create("scoreboard_fifo", this);
    
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        reference_model.valid_yapp_out.connect(scoreboard.yapp_in);

        //yapp_exprt.connect(reference_model.yapp_in);
        //hbus_exprt.connect(reference_model.hbus_in);

        //chan0_exprt.connect(scoreboard.chan0_in);
        //chan1_exprt.connect(scoreboard.chan1_in);
        //chan2_exprt.connect(scoreboard.chan2_in);

        yapp_exprt.connect(scoreboard_fifo.yapp_fifo.analysis_export);
        hbus_exprt.connect(scoreboard_fifo.hbus_fifo.analysis_export);
        
        chan0_exprt.connect(scoreboard_fifo.chan0_fifo.analysis_export);
        chan1_exprt.connect(scoreboard_fifo.chan1_fifo.analysis_export);
        chan2_exprt.connect(scoreboard_fifo.chan2_fifo.analysis_export);

    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Env starting simulation phase", UVM_LOW)
    endfunction

endclass