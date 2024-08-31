// Top-level chip interface modules
// Links together all components
module ChipInterface
(input logic CLOCK_50,
input logic [3:0] KEY,
input logic [17:0] SW,
output logic [6:0] HEX0, HEX1, HEX2, HEX3,
HEX4, HEX5, HEX6, HEX7,
output logic [7:0] VGA_R, VGA_G, VGA_B,
output logic VGA_BLANK_N, VGA_CLK, VGA_SYNC_N,
output logic VGA_VS, VGA_HS);

  // VGA driver row and col
  logic [8:0] row;
  logic [9:0] col;
  // VGA output intermediate signals
  logic VGA_R_on, VGA_G_on, VGA_B_on, blank;
  logic reset;

  // Assign VGA values
  assign VGA_BLANK_N = ~blank;
  assign VGA_SYNC_N = 1'b0;
  assign VGA_CLK = ~CLOCK_50;

  vga v(.CLOCK_50, .VS(VGA_VS), .HS(VGA_HS), .row, .col, .reset, .blank);

  logic [11:0] numma;
  logic numma_display;

  vga_number #(100,100,3) n (.number(numma), .row, .col, .display(numma_display));

  always_comb begin
    VGA_R = 8'h00;
    VGA_G = 8'h00;
    VGA_B = 8'H00;
    if (numma_display) begin
      VGA_R = 8'hFF;
      VGA_G = 8'hFF;
      VGA_B = 8'HFF;
    end
  end

  always_ff @(posedge SW[0], posedge reset) begin
    if (reset)
      numma <= 11'd0;
    else if (KEY[0]) 
      numma <= numma + 11'd1;
    else
      numma <= numma;
  end

  SevenSegmentDisplay numb (.BCD6(numma), .HEX6, .blank(7'b0100000));
  


endmodule: ChipInterface
