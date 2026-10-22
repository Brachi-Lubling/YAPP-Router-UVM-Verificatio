class router_simple_mcseq extends uvm_sequence;
    
      // Required macro for sequences automation
  `uvm_object_utils(router_simple_mcseq)
  `uvm_declare_p_sequencer(router_mcsequencer)

  hbus_small_packet_seq h_small;
  hbus_read_max_pkt_seq h_read_mx_pkt;
  yapp_012_seq y_012;
  hbus_set_default_regs_seq h_def_regs;
  yapp_6_packets y_6_p;

  // Constructor
  function new(string name="router_simple_mcseq");
    super.new(name);
  endfunction

  virtual task pre_body();
    if (starting_phase != null)
        starting_phase.raise_objection(this, get_type_name());
  endtask

  task body();
    `uvm_do_on(h_small,p_sequencer.hbus_seqr)
    `uvm_do_on(h_read_mx_pkt,p_sequencer.hbus_seqr)
    repeat(2)
        `uvm_do_on(y_012,p_sequencer.yapp_seqr)
    `uvm_do_on(h_def_regs,p_sequencer.hbus_seqr)
    `uvm_do_on(h_read_mx_pkt,p_sequencer.hbus_seqr)
    repeat(20)
      `uvm_do_on(y_6_p,p_sequencer.yapp_seqr)

  endtask

  virtual task post_body();
    if (starting_phase != null)
        starting_phase.drop_objection(this, get_type_name());
  endtask

endclass


  

