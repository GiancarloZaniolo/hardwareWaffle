
`default_nettype none

`define IMG_ROWS 32
`define IMG_COLS 32

module top;

  logic clk;

  logic [31:0] in_data1, in_data2, addr1, addr2, out_data1, result;
  logic rst, clk, we, complete;

  memory_export m(.*);
  waffle_solver #(`IMG_ROWS, `IMG_COLS) w(.*);

  initial begin
    clk = 0;
    rst = 0;
    #5
    rst = 1;
    #5;
    rst = 0;
    #5;
    forever #5 clk = ~clk;
  end

  always @(posedge clk) begin
    if(complete) begin
      $finish;
    end
  end

endmodule: top