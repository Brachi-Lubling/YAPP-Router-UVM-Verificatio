
class router_tb extends uvm_env;

    yapp_env yapp;
    channel_env chan0;
    channel_env chan1;
    channel_env chan2;
    hbus_env hbus;
    clock_and_reset_env clock_and_reset;

    router_mcsequencer mc_sequencer;
    router_module_env router_env;

    yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5 yapp_rm;
    hbus_reg_adapter   reg2hbus;

    `uvm_component_utils_begin(router_tb)
        `uvm_field_object(yapp_rm, UVM_ALL_ON)
    `uvm_component_utils_end

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        `uvm_info(get_type_name(), "build phase of tb is executed", UVM_HIGH)

        yapp = yapp_env::type_id::create("yapp", this);

        chan0 = channel_env::type_id::create("chan0", this);
        chan1 = channel_env::type_id::create("chan1", this);
        chan2 = channel_env::type_id::create("chan2", this);

        uvm_config_int::set(this, "chan0", "channel_id", 0);
        uvm_config_int::set(this, "chan1", "channel_id", 1);
        uvm_config_int::set(this, "chan2", "channel_id", 2);

        hbus = hbus_env::type_id::create("hbus", this);

        uvm_config_int::set(this, "hbus", "num_masters", 1);
        uvm_config_int::set(this, "hbus", "num_slaves", 0);

        clock_and_reset = clock_and_reset_env::type_id::create("clock_and_reset", this);
        mc_sequencer = router_mcsequencer::type_id::create("mc_sequencer", this);
        router_env = router_module_env::type_id::create("router_env", this);

        yapp_rm = yapp_router_regs_vendor_Cadence_Design_Systems_library_Yapp_Registers_version_1_5::type_id::create("yapp_rm", this);
        yapp_rm.build();
        yapp_rm.lock_model();
        yapp_rm.set_hdl_path_root("hw_top.dut");
        yapp_rm.default_map.set_auto_predict(1);

        reg2hbus = hbus_reg_adapter::type_id::create("reg2hbus",this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "connect phase of router_tb is executed", UVM_HIGH)

        mc_sequencer.yapp_seqr = yapp.agent.sequencer;
        mc_sequencer.hbus_seqr = hbus.masters[0].sequencer;

        yapp.agent.monitor.yapp_out.connect(router_env.yapp_exprt);
        hbus.masters[0].monitor.item_collected_port.connect(router_env.hbus_exprt);
        chan0.rx_agent.monitor.item_collected_port.connect(router_env.chan0_exprt);
        chan1.rx_agent.monitor.item_collected_port.connect(router_env.chan1_exprt);
        chan2.rx_agent.monitor.item_collected_port.connect(router_env.chan2_exprt);

        yapp_rm.default_map.set_sequencer(hbus.masters[0].sequencer, reg2hbus);

    endfunction

    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "tb starting simulation phase", UVM_LOW);
    endfunction

endclass
