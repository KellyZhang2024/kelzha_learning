`ifndef __SIMPLE_REQ_ACK_UVC_CFG__
`define __SIMPLE_REQ_ACK_UVC_CFG__
//------------------------------------------------------------------------------
// Description
// 
// 
//------------------------------------------------------------------------------


typedef enum { LEVEL_TRIGGER,
               PULSE_TRIGGER
             } req_ack_protocol_enum;

class simple_req_ack_uvc_cfg extends uvm_object;

  uvm_active_passive_enum is_active = UVM_PASSIVE;
  string interface_path = "unset-interface_path";
  req_ack_protocol_enum	signal_type=LEVEL_TRIGGER;
  int inst_index = 0; //used if DUT has several same req ack signal pair

   `uvm_object_utils_begin(simple_req_ack_uvc_cfg)
      `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
      `uvm_field_enum(req_ack_protocol_enum, signal_type, UVM_DEFAULT)
      `uvm_field_string(interface_path, UVM_ALL_ON)
      `uvm_field_int(inst_index, UVM_ALL_ON)
   `uvm_object_utils_end

   function new (string _name="simple_req_ack_uvc_cfg");
      super.new(_name);
   endfunction : new

endclass: simple_req_ack_uvc_cfg

`endif //__SIMPLE_REQ_ACK_UVC_CFG__
