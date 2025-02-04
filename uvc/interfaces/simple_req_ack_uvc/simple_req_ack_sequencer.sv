`ifndef __SIMPLE_REQ_ACK_SEQUENCER__
`define __SIMPLE_REQ_ACK_SEQUENCER__

class simple_req_ack_sequencer extends uvm_sequencer #(simple_req_ack_transaction);

  `uvm_component_utils(simple_req_ack_sequencer)
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
endclass : simple_req_ack_sequencer


`endif //__SIMPLE_REQ_ACK_SEQUENCER__
