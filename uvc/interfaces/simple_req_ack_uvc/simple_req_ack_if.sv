`ifndef __SIMPLE_REQ_ACK_IF__
`define __SIMPLE_REQ_ACK_IF__
interface simple_req_ack_if(
    input 			 clock,
    input 			 reset,
    inout            req,       
    inout            ack      
);
   /** number of clock edges (ignore reset and expire)
   *   used by monitor for start and end time of signals
   */
   bit [63:0] clock_time = 0; 
   // Record the clock time
   always @(posedge clock)
     clock_time <= clock_time + 1;
 
   clocking monitor_cb @(posedge clock);
     default input #1step output #0;
      input clock_time;
      input reset;
      input req;
      input ack;
   endclocking: monitor_cb

   modport monitor_cb_mp (clocking monitor_cb);

   clocking driver_cb @(posedge clock);
      default input #1step output #0;
      input reset;
      output req;
      input ack;
   endclocking: driver_cb

   modport driver_cb_mp (clocking driver_cb);

endinterface : simple_req_ack_if
`endif //__SIMPLE_REQ_ACK_IF__
