`ifndef __SIMPLE_REQ_ACK_DRIVER__
`define __SIMPLE_REQ_ACK_DRIVER__
//------------------------------------------------------------------------------
// Description: change the behavior if it is not same as DUT
// pulse trigger - exit_req_delay is used as pulse length
// req   ____transmit_delay|-exit_req_delay|____________
// ack   ___________________________________|-------------
// level trigger
// req   ____transmit_delay|---exit_req_delay|____________
// ack   _____________________|--------------------------
//------------------------------------------------------------------------------

class simple_req_ack_driver extends uvm_driver #(simple_req_ack_transaction);

  protected virtual simple_req_ack_if.driver_cb_mp  vif;

  simple_req_ack_uvc_cfg uvc_cfg;
  simple_req_ack_transaction REQS[$];

  `uvm_component_utils_begin(simple_req_ack_driver)
    `uvm_field_object(uvc_cfg, UVM_ALL_ON)
  `uvm_component_utils_end

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(simple_req_ack_uvc_cfg)::get(this,"", "uvc_cfg", uvc_cfg))
          `uvm_fatal("NOCREDITCFG",{"uvc cfg object must be set for: ",get_full_name(),".uvc_cfg"})
    `uvmkit_retrieve_vif(vif, simple_req_ack_if, uvc_cfg.interface_path)
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "run_phase() begin", UVM_LOW)
    forever begin
       reset_signals();
       wait(vif.driver_cb.reset === 1'b0);
       @(vif.driver_cb);
       fork begin
	      process pid = process::self();
	      fork
            begin
	          wait (vif.driver_cb.reset === 1'b1);
	          pid.kill();
	        end
            begin
              get_and_drive();
            end
	      join
	   end join
    end
    `uvm_info(get_type_name(), "run_phase() end", UVM_LOW)
  endtask : run_phase

  // user defined tasks
  virtual protected task get_and_drive();
    `uvm_info(get_type_name(), "get_and_drive() begin", UVM_HIGH)
    fork: get_and_drive
      forever begin
        seq_item_port.get_next_item(req);
        $cast(rsp, req.clone());
        rsp.set_id_info(req);
        queue_request(rsp);
        seq_item_port.item_done();
        seq_item_port.put_response(rsp);//put_response() is a blocking method, so the sequence must do a corresponding get_response(rsp)
      end
      drive_transfer();
    join_none: get_and_drive
    `uvm_info(get_type_name(), "get_and_drive() end", UVM_HIGH)
  endtask : get_and_drive

  // reset_signals
  virtual protected task reset_signals();
      clear_signals();
      REQS.delete();
  endtask : reset_signals

  virtual protected task clear_signals();
    vif.driver_cb.req <= 'h0;
  endtask : clear_signals

  virtual protected task queue_request(simple_req_ack_transaction trans);
    simple_req_ack_transaction t_req;
    $cast(t_req, trans.clone());
    REQS.push_back(t_req);
  endtask : queue_request

  // drive_transfer
  virtual protected task drive_transfer();
    simple_req_ack_transaction trans;
    forever begin
        while(vif.driver_cb.ack===1&&uvc_cfg.signal_type==LEVEL_TRIGGER)@(vif.driver_cb);
        while(REQS.size()==0)begin
            clear_signals();//
            @(vif.driver_cb);
        end
        trans = REQS.pop_front();
        if(trans.transmit_delay != 0) 
            repeat(trans.transmit_delay)@(vif.driver_cb);
	    vif.driver_cb.req  <= 1'b1;
	    `uvm_info(get_type_name(),$sformatf("Send a req::Assert\n"), UVM_LOW)
		if(uvc_cfg.signal_type==PULSE_TRIGGER) begin
           	repeat(trans.exit_req_delay+1)@(vif.driver_cb);
			vif.driver_cb.req  <= 1'b0;
            @(vif.driver_cb iff vif.driver_cb.ack===1);
            @(vif.driver_cb);
			`uvm_info(get_type_name(),$sformatf("get a req clear\n"), UVM_LOW)
		end
        else begin
	    	@(vif.driver_cb iff vif.driver_cb.ack===1);
        	if(trans.exit_req_delay != 0) 
            	repeat(trans.exit_req_delay)@(vif.driver_cb);
	    	vif.driver_cb.req  <= 1'b0;
	    	`uvm_info(get_type_name(),$sformatf("Send a req::DE-Assert\n"), UVM_LOW)
		end
    end
    
  endtask:  drive_transfer

  virtual task wait_req_queue_empty();
      repeat(10000)begin
        repeat(200) 
          @(vif.driver_cb);
        if(REQS.size() == 0) 
          break;
        else
          `uvm_info(get_type_name(), $psprintf("REQS size is %d", REQS.size()),UVM_LOW)
      end
      if(REQS.size() != 0)
        `uvm_error(get_type_name(), $psprintf("ERROR: poll req queue empty timeout"));
  endtask : wait_req_queue_empty
endclass : simple_req_ack_driver

`endif //__SIMPLE_REQ_ACK_DRIVER__
