
`default_nettype none

`define IMG_ROWS 16
`define IMG_COLS 16

module top;

  logic clk;

  logic [`IMG_ROWS-1:0] [`IMG_COLS-1:0] [31:0] memory_input;

  logic [31:0] result;

  memory_export m(.memory_output(memory_input));
  waffle_solver #(`IMG_ROWS, `IMG_COLS) w(.memory_input, .result);

  initial begin
    clk = 0;
    #500;
    clk = 1;
    #500;
    clk = 0;
    $finish;
  end

endmodule: top