
`default_nettype none

// `define IMG_ROWS 4
// `define IMG_COLS 4

module memory_export
  #(parameter IMG_ROWS=4, parameter IMG_COLS=4)
  (output logic [IMG_ROWS-1:0] [31:0] in_data1, in_data2,
  input logic rst, clk, we,
  input logic [IMG_ROWS-1:0] [31:0] write_data,
  input logic [31:0] addr1, addr2, addr_write);

  genvar i;
  generate
    for(i = 0; i < IMG_ROWS; i++) begin: mem_rows
      sram #(IMG_COLS, 32, 1) s
        (.clk, .rst_l(~rst), .we,
        .read_addr_1(addr1[$clog2(IMG_COLS)-1:0]), .read_addr_2(addr2[$clog2(IMG_COLS)-1:0]), .write_addr(addr_write[$clog2(IMG_COLS)-1:0]),
        .write_data(write_data[i]), .read_data_1(in_data1[i]), .read_data_2(in_data2[i]));
    end
  endgenerate


endmodule: memory_export


