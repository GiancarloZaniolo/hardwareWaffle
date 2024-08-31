/*
@file vga_number.sv

This file contains modules to display a number on a VGA screen.

*/

`default_nettype none

`define SEGMENT_WIDTH 50
`define SEGMENT_HEIGHT 10

module vga_number
  #(parameter ROW=100, COL=100, DIGIT_COUNT=8)
  (input logic [(DIGIT_COUNT*4)-1:0] number,
  input logic [8:0] row,
  input logic [9:0] col,
  output logic display);

  // NOTE: Slightly strange behavior, most significant bits get low index
  logic [DIGIT_COUNT-1:0] display_digit;
  logic [DIGIT_COUNT-1:0] display_digit_acc;

  assign display = display_digit_acc[DIGIT_COUNT-1];

  // Create a bunch of evenly spaced digits
  genvar i;
  generate
    for (i = 0; i < DIGIT_COUNT; i++) begin : some_name
      vga_digit #(ROW,COL+(i*`SEGMENT_WIDTH*2)) 
        d(.digit(number[((DIGIT_COUNT-i)*4)-1:((DIGIT_COUNT-i)*4)-4]),
        .row, .col, .display(display_digit[i]));

      case (i) 
      0: begin
        assign display_digit_acc[i] = display_digit[i];
      end
      default: begin
        assign display_digit_acc[i] = display_digit_acc[i-1] | display_digit[i];
      end
      endcase

    end

  endgenerate
endmodule: vga_number


// A single digit
module vga_digit
  #(parameter ROW=100, COL=100)
  (input logic [3:0] digit,
  input logic [8:0] row,
  input logic [9:0] col,
  output logic display);

  // NOTE: Segment 0 gets index 0
  logic [6:0] enable_segment;
  logic [6:0] display_segment;
  logic [6:0] display_segment_acc;

  assign display = display_segment_acc[6];
  
  genvar i;
  generate
    for (i = 0; i < 7; i++) begin : some_name
      vga_segment #(ROW, COL, i) s(.en(enable_segment[i]), .row, .col, 
        .display_final(display_segment[i]));

      case (i)
      0: begin
        assign display_segment_acc[i] = display_segment[i];
      end
      default: begin
        assign display_segment_acc[i] = display_segment_acc[i-1] | display_segment[i];
      end
      endcase
    end
  endgenerate

  always_comb begin
    case (digit)
    4'h0: enable_segment = 7'b0111111;
    4'h1: enable_segment = 7'b0000110;
    4'h2: enable_segment = 7'b1011011;
    4'h3: enable_segment = 7'b1001111;
    4'h4: enable_segment = 7'b1100110;
    4'h5: enable_segment = 7'b1101101;
    4'h6: enable_segment = 7'b1111101;
    4'h7: enable_segment = 7'b0000111;
    4'h8: enable_segment = 7'b1111111;
    4'h9: enable_segment = 7'b1100111;
    4'ha: enable_segment = 7'b1110111;
    4'hb: enable_segment = 7'b1111100;
    4'hc: enable_segment = 7'b1011000;
    4'hd: enable_segment = 7'b1011110;
    4'he: enable_segment = 7'b1111001;
    4'hf: enable_segment = 7'b1110001;
    default: enable_segment = 7'b0110110;
    endcase

  end

endmodule: vga_digit



// NOTE: Seven segments are typically named with a letter. Our convention
//  is A=0,B=1... etc.
//   0
// 5   1
//   6
// 4   2
//   3
module vga_segment
  #(parameter ROW=100, COL=100, SEGMENT=0)
  (input logic en,
  input logic [8:0] row,
  input logic [9:0] col,
  output logic display_final);


  logic display;
  assign display_final = display & en;

  generate
    case (SEGMENT)
    0: begin 
      assign display = 
        (row >= ROW) &&
        (row <= ROW + `SEGMENT_HEIGHT) &&
        (col >= COL) &&
        (col <= COL + `SEGMENT_WIDTH);
    end
    1: begin 
      assign display = 
        (row >= ROW) &&
        (row <= ROW + `SEGMENT_WIDTH) &&
        (col >= COL + `SEGMENT_WIDTH - `SEGMENT_HEIGHT) &&
        (col <= COL + `SEGMENT_WIDTH);
    end
    2: begin 
      assign display = 
        (row >= ROW + `SEGMENT_WIDTH) &&
        (row <= ROW + `SEGMENT_WIDTH + `SEGMENT_WIDTH) &&
        (col >= COL + `SEGMENT_WIDTH - `SEGMENT_HEIGHT) &&
        (col <= COL + `SEGMENT_WIDTH);
    end
    3: begin 
      assign display = 
        (row >= ROW + `SEGMENT_WIDTH + `SEGMENT_WIDTH - `SEGMENT_HEIGHT) &&
        (row <= ROW + `SEGMENT_WIDTH + `SEGMENT_WIDTH) &&
        (col >= COL) &&
        (col <= COL + `SEGMENT_WIDTH);
    end
    4: begin 
      assign display = 
        (row >= ROW + `SEGMENT_WIDTH) &&
        (row <= ROW + `SEGMENT_WIDTH + `SEGMENT_WIDTH) &&
        (col >= COL) &&
        (col <= COL + `SEGMENT_HEIGHT);
    end
    5: begin 
      assign display = 
        (row >= ROW) &&
        (row <= ROW + `SEGMENT_WIDTH) &&
        (col >= COL) &&
        (col <= COL + `SEGMENT_HEIGHT);
    end
    6: begin 
      assign display = 
        (row >= ROW + `SEGMENT_WIDTH - (`SEGMENT_HEIGHT/2)) &&
        (row <= ROW + `SEGMENT_WIDTH + (`SEGMENT_HEIGHT/2)) &&
        (col >= COL) &&
        (col <= COL + `SEGMENT_WIDTH);
    end
    default: begin
      assign display = 1'b1;
    end
    endcase
  endgenerate


endmodule: vga_segment
