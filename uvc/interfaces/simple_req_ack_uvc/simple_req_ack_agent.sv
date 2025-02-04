`ifndef __SIMPLE_REQ_ACK_AGENT__
`define __SIMPLE_REQ_ACK_AGENT__
//------------------------------------------------------------------------------
// Description:
// 
//
//------------------------------------------------------------------------------

class simple_req_ack_agent extends uvm_agent;

  simple_req_ack_driver    driver;
  simple_req_ack_sequencer sequencer;
  simple_req_ack_monitor   monitor;
  simple_req_ack_uvc_cfg   uvc_cfg;

  /** Provide implementations of virtual methods such as get_type_name and create */

  `uvm_component_utils_begin(simple_req_ack_agent)
    `uvm_field_object(uvc_cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  // build_phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(simple_req_ack_uvc_cfg)::get(this,"", "uvc_cfg", uvc_cfg))
      `uvm_fatal("NOCREDITCFG",{"uvc cfg object must be set for: ",get_full_name(),".uvc_cfg"})
    uvm_config_db#(simple_req_ack_uvc_cfg)::set(this,"*", "uvc_cfg", uvc_cfg);

    monitor = simple_req_ack_monitor::type_id::create("monitor", this);
    if(uvc_cfg.is_active == UVM_ACTIVE) begin
      driver    = simple_req_ack_driver::type_id::create("driver", this);
      sequencer = simple_req_ack_sequencer::type_id::create("sequencer", this);
    end
  endfunction : build_phase

  // connect_phase
  function void connect_phase(uvm_phase phase);
    if(uvc_cfg.is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction : connect_phase

  // user defined tasks
  virtual task poll_req_queue_empty();
    if(uvc_cfg.is_active == UVM_ACTIVE) begin
      driver.wait_req_queue_empty();
    end
  endtask : poll_req_queue_empty

endclass : simple_req_ack_agent

`endif //__SIMPLE_REQ_ACK_AGENT__
