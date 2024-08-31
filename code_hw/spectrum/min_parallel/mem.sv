

`default_nettype none

// `define IMG_ROWS 4
// `define IMG_COLS 4

// TODO move our digit somewhere into the repository

module memory_export
  #(parameter IMG_ROWS=4, parameter IMG_COLS=4)
  (output logic [31:0] in_data1, in_data2,
  input logic rst, clk, we,
  input logic [31:0] addr1,out_data1, addr2);

  logic [(IMG_ROWS*IMG_ROWS)-1:0] [31:0] M;


  always_ff @(posedge clk, posedge rst) begin
    if(rst == 1'd1) begin
      // M[0] = 32'd0;
      // M[1] = 32'd1;
      // M[2] = 32'd2;
      // M[3] = 32'd3;
      // M[4] = 32'd4;
      // M[5] = 32'd5;
      // M[6] = 32'd6;
      // M[7] = 32'd7;
      // M[8] = 32'd8;
      // M[9] = 32'd9;
      // M[10] = 32'd10;
      // M[11] = 32'd11;
      // M[12] = 32'd12;
      // M[13] = 32'd13;
      // M[14] = 32'd14;
      // M[15] = 32'd15;
      // M[0] <= -32'd1;
      // M[1] <= -32'd1;
      // M[2] <= -32'd1;
      // M[3] <= -32'd1;
      // M[4] <= -32'd1;
      // M[5] <= 32'd1;
      // M[6] <= 32'd1;
      // M[7] <= -32'd1;
      // M[8] <= -32'd1;
      // M[9] <= 32'd1;
      // M[10] <= 32'd1;
      // M[11] <= -32'd1;
      // M[12] <= -32'd1;
      // M[13] <= -32'd1;
      // M[14] <= -32'd1;
      // M[15] <= -32'd1;
      M <= {$bits(M){1'd1}};
    end else begin
      if(we)
        M[addr1] <= out_data1;
    end
  end

  assign in_data1 = M[addr1];
  assign in_data2 = M[addr2];

endmodule: memory_export


