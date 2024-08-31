module vga_number
  #(parameter ROW=100, DIGIT_COUNT=8)
  (input logic [DIGIT_COUNT*4:0] number,
   input logic [8:0] row,
   input logic [9:0] col,
   output logic display);

  logic [DIGIT_COUNT-1:0] display_digit;
  logic [DIGIT_COUNT:0] display_digit_acc;

  // Create a bunch of evenly spaced digits
  genvar i;
  generate
    for (i = 0; i < DIGIT_COUNT; i++) begin : some_name
      vga_digit #(ROW) d(.row(row), .col(col), .display(display_digit[i]));

      if (i == 0) begin
        display_digit_acc[i] = display_digit[i];
      end else begin
        display_digit_acc[i] = display_digit_acc[i-1] | display_digit[i];
      end
    end
  endgenerate

  assign display = display_digit_acc[DIGIT_COUNT];
endmodule vga_number



module vga_digit
  #(parameter ROW=100)
  (input logic [8:0] row,
  input logic [9:0] col,
  output logic display);

  assign display = 1'b1;

endmodule vga_digit