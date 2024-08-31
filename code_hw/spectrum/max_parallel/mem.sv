

`default_nettype none

`define IMG_ROWS 4
`define IMG_COLS 4

module memory_export
  (output logic [`IMG_ROWS-1:0] [`IMG_COLS-1:0] [31:0] memory_output);

  // assign memory_output = {{32'd4, 32'd5, 32'd8, 32'd5},{-32'd10,-32'd3,-32'd10,32'd5}};
  // assign memory_output = {{1},{-1},{-1},{-1},{1},{1},{-1},{-1}};
  assign memory_output = {{-1,-1,-1,-1},{-1,1,1,-1},{-1,1,1,-1},{-1,-1,-1,-1}};



endmodule: memory_export