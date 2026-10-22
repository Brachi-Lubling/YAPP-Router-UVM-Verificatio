class base_test extends uvm_test;

    `uvm_component_utils(base_test)

    router_tb tb;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase", "default_sequence", yapp_5_packets::get_type());
        tb=router_tb::type_id::create("tb",this);
        `uvm_info(get_type_name(), "build phase of base_test is executed", UVM_HIGH)
        uvm_config_int::set(this, "*", "recording_detail", 1);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    virtual task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection ();
        obj.set_drain_time(this, 200ns);
    endtask

    virtual function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction

endclass

class simple_test extends base_test;

  `uvm_component_utils(simple_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                            "default_sequence",
                                            clk10_rst5_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.yapp.agent.sequencer.run_phase",
                                            "default_sequence",
                                            yapp_012_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.chan0.rx_agent.sequencer.run_phase",
                                            "default_sequence",
                                            channel_rx_resp_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.chan1.rx_agent.sequencer.run_phase",
                                            "default_sequence",
                                            channel_rx_resp_seq::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.chan2.rx_agent.sequencer.run_phase",
                                            "default_sequence",
                                            channel_rx_resp_seq::type_id::get());

    super.build_phase(phase);
    
    //set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
  endfunction

endclass

class simple_mcseq_test extends base_test;
  `uvm_component_utils(simple_mcseq_test)

  function new(string name , uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.clock_and_reset.agent.sequencer.run_phase",
                                            "default_sequence",
                                            clk10_rst5_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.chan?.rx_agent.sequencer.run_phase",
                                            "default_sequence",
                                            channel_rx_resp_seq::type_id::get());

    uvm_config_db#(uvm_object_wrapper)::set(this, "tb.mc_sequencer.run_phase",
                                            "default_sequence",
                                            router_simple_mcseq::type_id::get());

    //set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());

    super.build_phase(phase);

  endfunction

endclass

class  uvm_reset_test extends base_test;

  uvm_reg_hw_reset_seq reset_seq;

  // component macro
  `uvm_component_utils(uvm_reset_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);

    super.build_phase(phase); 

    uvm_reg::include_coverage("*", UVM_NO_COVERAGE);  

    uvm_config_db#(uvm_object_wrapper)::set(this,
        "tb.clock_and_reset.agent.sequencer.run_phase",
        "default_sequence",
        clk10_rst5_seq::type_id::get());  

    reset_seq = uvm_reg_hw_reset_seq::type_id::create("reset_seq"); 

  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
    // Set the model property of the sequence to our Register Model instance
    // Update the RHS of this assignment to match your instance names. Syntax is:
    //  <testbench instance>.<register model instance>
    reset_seq.model = tb.yapp_rm;
    // Execute the sequence (sequencer is already set in the testbench)
    reset_seq.start(null);
    phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : uvm_reset_test

class  uvm_mem_walk_test extends base_test;

  uvm_mem_walk_seq mem_walk_seq;

  // component macro
  `uvm_component_utils(uvm_mem_walk_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);

    super.build_phase(phase); 

    uvm_reg::include_coverage("*", UVM_NO_COVERAGE);  

    uvm_config_db#(uvm_object_wrapper)::set(this,
        "tb.clock_and_reset.agent.sequencer.run_phase",
        "default_sequence",
        clk10_rst5_seq::type_id::get());  

    mem_walk_seq = uvm_mem_walk_seq::type_id::create("mem_walk_seq"); 

  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
    phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
    // Set the model property of the sequence to our Register Model instance
    // Update the RHS of this assignment to match your instance names. Syntax is:
    //  <testbench instance>.<register model instance>
    mem_walk_seq.model = tb.yapp_rm;
    // Execute the sequence (sequencer is already set in the testbench)
    mem_walk_seq.start(null);
    phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : uvm_mem_walk_test


// ==== NOT USE NOW ====

// class short_packet_test extends base_test;

//     `uvm_component_utils(short_packet_test)

//     function new(string name, uvm_component parent);
//         super.new(name,parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         `uvm_info(get_type_name(), "build phase of short_packet_test is executed", UVM_HIGH)
//         set_type_override_by_type(yapp_packet::get_type(),short_yapp_packet::get_type());
//     endfunction

//     virtual function void end_of_elaboration_phase(uvm_phase phase);
//         uvm_top.print_topology();
//     endfunction

// endclass : short_packet_test

// class set_config_test extends base_test;

//     `uvm_component_utils(set_config_test)

//     function new(string name, uvm_component parent);
//         super.new(name,parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         uvm_config_int::set(this,"tb.yapp.agent","is_active",UVM_PASSIVE);
//         super.build_phase(phase);
//         `uvm_info(get_type_name(), "build phase of set_config_test is executed", UVM_HIGH)
//     endfunction

// endclass : set_config_test

// class incr_payload_test extends base_test;
//     `uvm_component_utils(incr_payload_test)

//     function new(string name, uvm_component parent);
//         super.new(name,parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase", "default_sequence", yapp_incr_payload_seq::get_type());
//         super.build_phase(phase);
//         yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
//         `uvm_info(get_type_name(), "build phase of incr_payload_test is executed", UVM_HIGH)
//     endfunction

// endclass : incr_payload_test

// class  exhaustive_seq_test extends base_test;
//     `uvm_component_utils( exhaustive_seq_test)

//     function new(string name, uvm_component parent);
//         super.new(name,parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase", "default_sequence", yapp_exhaustive_seq::get_type());
//         super.build_phase(phase);
//         yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
//         `uvm_info(get_type_name(), "build phase of  exhaustive_seq_test is executed", UVM_HIGH)
//     endfunction

// endclass :  exhaustive_seq_test

// class yapp_012_test extends base_test;

//     `uvm_component_utils( yapp_012_test)

//     function new(string name, uvm_component parent);
//         super.new(name,parent);
//     endfunction

//     virtual function void build_phase(uvm_phase phase);
//         uvm_config_wrapper::set(this, "tb.yapp.agent.sequencer.run_phase", "default_sequence", yapp_012_seq::get_type());
//         super.build_phase(phase);
//         yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());
//         `uvm_info(get_type_name(), "build phase of  yapp_012_test is executed", UVM_HIGH)
//     endfunction
// endclass