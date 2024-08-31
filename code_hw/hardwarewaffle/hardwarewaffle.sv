`default_nettype none

// module hardwarewaffle;
//     logic clk, rst_l;
//     logic last_inputs;
//     logic [31:0] waffle_val;
    
      
//     FAST_WAFFLE fw(.clk, .rst_l, .last_inputs, .waffle_val);
    
//     initial begin 
//       clk = 0;
//       rst_l = 0;
//       rst_l <= 1;
//       forever #5 clk = ~clk;
//     end
//     initial begin
      
//       @(posedge last_inputs);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);
//       @(posedge clk);


      

//       $finish;

        
//     end
// endmodule: hardwarewaffle

module hardwarewaffle (input logic [3:0] SW,
                       input logic [1:0] KEY,
                       input logic FPGA_CLK1_50,
                      output logic [7:0] LED);
    logic clear_l, sw_1, sw_0;
    logic last_inputs;
    logic [31:0] waffle_val;
    
    Synchronizer s1(.async(KEY[0]), .clock(FPGA_CLK1_50), .sync(clear_l));
    Synchronizer s2(.async(SW[0]), .clock(FPGA_CLK1_50), .sync(sw_0));
    Synchronizer s3(.async(SW[1]), .clock(FPGA_CLK1_50), .sync(sw_1));

    always_comb begin
      LED = waffle_val[7:0];
      if(~sw_1 && ~sw_0) begin
        LED = waffle_val[7:0];  

      end
      else if(~sw_1 && sw_0) begin
        LED = waffle_val[15:8];

      end
      else if(sw_1 && ~sw_0) begin
        LED = waffle_val[23:16];

      end
      else if(sw_1 && sw_0) begin
        LED = waffle_val[31:24];

      end
    end

      
    FAST_WAFFLE fw(.clk(FPGA_CLK1_50), .rst_l(clear_l), .last_inputs, .waffle_val);
    
endmodule: hardwarewaffle

module Synchronizer
  (input logic async, clock,
   output logic sync);
  
  logic temp;
  always_ff @(posedge clock) begin
    temp <= async;
    sync <= temp;
  end
endmodule: Synchronizer