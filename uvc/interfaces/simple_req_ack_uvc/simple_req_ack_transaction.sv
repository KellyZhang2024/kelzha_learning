`ifndef __SIMPLE_REQ_ACK_TRANSACTION__
`define __SIMPLE_REQ_ACK_TRANSACTION__


typedef enum { NOP,
               REQ_ASSERT,
               ACK_ASSERT,
               REQ_DEASSERT,
               ACK_DEASSERT
             } simple_req_ack_enum;

//------------------------------------------------------------------------------
//
// CLASS: simple_req_ack_transacation
//
//------------------------------------------------------------------------------

class simple_req_ack_transaction extends uvm_sequence_item;                                  

  rand int unsigned            	transmit_delay;
  rand int unsigned             exit_req_delay; //for pulse mode, this delay will be used as pulse length
  
  simple_req_ack_enum           req_ack_stat;

  bit [63:0] start_time;
  bit [63:0] end_time;
  
  int inst_index= 0;
  constraint c_transmit_delay { 
    transmit_delay <= 500;
    exit_req_delay <= 500; 
  }

  `uvm_object_utils_begin(simple_req_ack_transaction)
    `uvm_field_enum     (simple_req_ack_enum, req_ack_stat, UVM_DEFAULT)
    `uvm_field_int      (inst_index, UVM_DEFAULT)
    `uvm_field_int      (exit_req_delay, UVM_DEFAULT)
    `uvm_field_int      (transmit_delay, UVM_DEFAULT)
    `uvm_field_int      (start_time, UVM_ALL_ON|UVM_DEC|UVM_NORECORD|UVM_NOCOMPARE)
    `uvm_field_int      (end_time, UVM_ALL_ON|UVM_DEC|UVM_NORECORD|UVM_NOCOMPARE)
  `uvm_object_utils_end

  // new - constructor
  function new (string name = "simple_req_ack_transaction_inst");
    super.new(name);
  endfunction : new
endclass : simple_req_ack_transaction

`endif //__SIMPLE_REQ_ACK_TRANSACTION__
