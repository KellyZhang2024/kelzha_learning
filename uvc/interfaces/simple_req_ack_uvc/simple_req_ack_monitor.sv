`ifndef __SIMPLE_REQ_ACK_MONITOR__
`define __SIMPLE_REQ_ACK_MONITOR__
//------------------------------------------------------------------------------
// Description:
//     
// 
//------------------------------------------------------------------------------

class simple_req_ack_monitor extends uvm_monitor;

  // This property is the virtual interfaced needed for this component to drive and view HDL signals.
  protected virtual simple_req_ack_if.monitor_cb_mp vif;
  simple_req_ack_uvc_cfg uvc_cfg;

  uvm_analysis_port #(simple_req_ack_transaction) trans_ap;

  simple_req_ack_transaction req_assert_collected;
  simple_req_ack_transaction req_deassert_collected;
  simple_req_ack_transaction ack_assert_collected;
  simple_req_ack_transaction ack_deassert_collected;

  `uvm_component_utils_begin(simple_req_ack_monitor)
    `uvm_field_object(uvc_cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_ap = new("trans_ap", this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(simple_req_ack_uvc_cfg)::get(this,"", "uvc_cfg", uvc_cfg))
          `uvm_fatal("NOCREDITCFG",{"uvc cfg object must be set for: ",get_full_name(),".uvc_cfg"})
    `uvmkit_retrieve_vif(vif, simple_req_ack_if, uvc_cfg.interface_path)
    req_assert_collected	= simple_req_ack_transaction::type_id::create("req_assert_collected");
    req_deassert_collected	= simple_req_ack_transaction::type_id::create("req_deassert_collected");
    ack_assert_collected	= simple_req_ack_transaction::type_id::create("ack_assert_collected");
    ack_deassert_collected	= simple_req_ack_transaction::type_id::create("ack_deassert_collected");
  endfunction: build_phase

  // run phase
  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "inside run()", UVM_LOW)
    forever begin
       reset();
       wait(vif.monitor_cb.reset === 1'b0);
       fork begin// Guard fork
	      process pid = process::self();
	      fork
            begin// active fork
	          wait (vif.monitor_cb.reset === 1'b1);
	          pid.kill();
	        end
            collect_reqs();
	      join
	   end join
    end
    `uvm_info(get_type_name(), "leaving run()", UVM_LOW)
  endtask : run_phase
  virtual task reset();
  endtask : reset


  // collect_reqs
  virtual protected task collect_reqs();
    simple_req_ack_transaction t_req;
    fork
        forever begin
           @(posedge vif.monitor_cb.req);
           req_assert_collected.req_ack_stat = REQ_ASSERT;
           req_assert_collected.inst_index = uvc_cfg.inst_index;
           req_assert_collected.start_time = vif.monitor_cb.clock_time;
           $cast(t_req, req_assert_collected.clone());
           trans_ap.write(t_req);
        end
        forever begin
           @(negedge vif.monitor_cb.req);
           req_deassert_collected.req_ack_stat = REQ_DEASSERT;
           req_deassert_collected.inst_index = uvc_cfg.inst_index;
           req_deassert_collected.start_time = vif.monitor_cb.clock_time;
           $cast(t_req, req_deassert_collected.clone());
           trans_ap.write(t_req);
        end
        forever begin
           @(posedge vif.monitor_cb.ack);
           ack_assert_collected.req_ack_stat = ACK_ASSERT;
           ack_assert_collected.inst_index = uvc_cfg.inst_index;
           ack_assert_collected.start_time = vif.monitor_cb.clock_time;
           $cast(t_req, ack_assert_collected.clone());
           trans_ap.write(t_req);
        end
        forever begin
           @(negedge vif.monitor_cb.ack);
           ack_deassert_collected.req_ack_stat = ACK_DEASSERT;
           ack_deassert_collected.inst_index = uvc_cfg.inst_index;
           ack_deassert_collected.start_time = vif.monitor_cb.clock_time;
           $cast(t_req, ack_deassert_collected.clone());
           trans_ap.write(t_req);
        end
    join
  endtask
endclass : simple_req_ack_monitor

`endif //__SIMPLE_REQ_ACK_MONITOR__
