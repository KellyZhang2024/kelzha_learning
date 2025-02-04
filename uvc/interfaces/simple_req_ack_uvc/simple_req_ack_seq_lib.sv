`ifndef __SIMPLE_REQ_ACK_BASE_SEQUENCE__
`define __SIMPLE_REQ_ACK_BASE_SEQUENCE__
//------------------------------------------------------------------------------
// Description
//     change dealy cycle as needed
// 
//------------------------------------------------------------------------------

virtual class simple_req_ack_base_sequence extends uvm_sequence #(simple_req_ack_transaction);

  rand int unsigned            			transmit_cycle_dly;
  rand int unsigned            			exit_req_cycle_dly;
    
  constraint cc_transmit_dly {
	transmit_cycle_dly <= 500;
	exit_req_cycle_dly <= 400;
  }

  function new(string name="simple_req_ack_base_sequence");
    super.new(name);
    set_automatic_phase_objection(1);
  endfunction

endclass : simple_req_ack_base_sequence

class simple_req_ack_base_seq extends simple_req_ack_base_sequence;

  function new(string name="simple_req_ack_base_seq");
    super.new(name);
  endfunction

  `uvm_object_utils(simple_req_ack_base_seq)

  virtual task body();
    `uvm_do_with(req,
      { req.transmit_delay == transmit_cycle_dly;
        req.exit_req_delay == exit_req_cycle_dly;
      }
    )
    get_response(rsp);//in driver put_response() is a blocking method, so the sequence must do a corresponding get_response(rsp)
  endtask

endclass : simple_req_ack_base_seq

`endif //__SIMPLE_REQ_ACK_BASE_SEQUENCE__
