
`default_nettype none

`define IMG_ROWS 32
`define IMG_COLS 32

module top;

  logic [`IMG_ROWS-1:0] [31:0] in_data1, in_data2, write_data;
  logic [31:0] addr1, addr2, addr_write;
  logic rst, clk, we, complete;

  memory_export #(`IMG_ROWS, `IMG_COLS) m(.*);
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