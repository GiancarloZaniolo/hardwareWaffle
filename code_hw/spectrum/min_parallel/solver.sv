/*

This file contains the implementation for a minimum hardware wafflelab solver

It basically does just one op per cycle

*/

`default_nettype none

module waffle_solver
  #(parameter IMG_ROWS=2, parameter IMG_COLS=4)
  (input logic [31:0] in_data1, in_data2,
  input logic rst, clk,
  output logic [31:0] addr1,out_data1, addr2, result,
  output logic complete, we);

  function logic [31:0] max2(logic [31:0] x, logic [31:0] y);
    return ($signed(x) > $signed(y)) ? x : y;
  endfunction: max2

  enum logic [1:0] {PREFIX_STEP,MCSS_STEP,COMPLETE} path_step; 

  assign complete = path_step == COMPLETE;  

  // Prefix sums
  logic [$clog2(IMG_ROWS):0] curr_row;
  logic [$clog2(IMG_COLS):0] curr_col, curr_col2;

  // MCSS step addresses are offset by -1. Need this to place into address 
  //  vector easily
  logic [$clog2(IMG_COLS)-1:0] curr_col_dec1_bits;
  assign curr_col_dec1_bits = curr_col[$clog2(IMG_COLS)-1:0] - 1;
  logic [$clog2(IMG_COLS)-1:0] curr_col2_dec1_bits;
  assign curr_col2_dec1_bits = curr_col2[$clog2(IMG_COLS)-1:0] - 1;

  // Difference between two column elements for a step of an mcss iteration
  logic [31:0] diff_local;

  // MCSS step addresses are offset by -1. Column 0 must output data value 0
  logic [31:0] in_data1_proc, in_data2_proc;
  assign in_data1_proc = curr_col == 0 ? 0 : in_data1;
  assign in_data2_proc = curr_col2 == 0 ? 0 : in_data2;

  // Values for MCSS iteration
  logic [31:0] curr_acc, next_acc;
  logic [31:0] curr_best, next_best;

  // Best mcss value found so far
  logic [31:0] mcss_best;
  assign result = mcss_best;

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      curr_row <= 0;
      curr_col <= 0;
      curr_acc <= 32'd0;
      path_step <= PREFIX_STEP;
      mcss_best <= 0;
      we <= 1;
    end else begin
      if(path_step == PREFIX_STEP) begin
        if(curr_row >= (IMG_ROWS-1) && curr_col >= (IMG_COLS-1)) begin
          path_step <= MCSS_STEP;
          curr_col <= 0;
          curr_col2 <= 0;
          curr_row <= 0;
          we <= 0;
          curr_best <= 0;
          curr_acc <= 0;

        end else if(curr_col == (IMG_COLS-1)) begin
          curr_col <= 0;
          curr_row <= curr_row + 1;
          curr_acc <= 32'd0;
        end else begin
          curr_col <= curr_col + 1;
          curr_acc <= next_acc;
        end

        
      end else if(path_step == MCSS_STEP) begin
        if(curr_row >= (IMG_ROWS-1) && (curr_col >= (IMG_COLS)) && (curr_col2 >= (IMG_COLS))) begin
          path_step <= COMPLETE;
        end else if(curr_row == (IMG_ROWS-1)) begin
          if(curr_col2 == (IMG_COLS)) begin
            curr_col <= curr_col + 1;
            curr_col2 <= curr_col + 1;
          end else begin
            curr_col2 <= curr_col2 + 1;
          end
          mcss_best <= max2(mcss_best,next_best);
          curr_row <= 0;
          curr_acc <= 0;
          curr_best <= 0;
        end else begin
          curr_row <= curr_row + 1;
          curr_acc <= next_acc;
          curr_best <= next_best;
        end
      end
    end

  end 

  always_comb begin
    if(path_step == PREFIX_STEP) begin
      addr1 = {{32-$clog2(IMG_ROWS)-$clog2(IMG_COLS){1'd0}}, curr_row[$clog2(IMG_ROWS)-1:0], curr_col[$clog2(IMG_COLS)-1:0]};
      next_acc = curr_acc + in_data1;
      out_data1 = next_acc;
    end else if(path_step == MCSS_STEP) begin
      addr1 = {{32-$clog2(IMG_ROWS)-$clog2(IMG_COLS){1'd0}}, curr_row[$clog2(IMG_ROWS)-1:0], curr_col_dec1_bits};
      addr2 = {{32-$clog2(IMG_ROWS)-$clog2(IMG_COLS){1'd0}}, curr_row[$clog2(IMG_ROWS)-1:0], curr_col2_dec1_bits};
      diff_local = in_data2_proc - in_data1_proc;
      next_acc = max2(0,curr_acc + diff_local);
      next_best = max2(curr_best,next_acc);
    end

  end

endmodule: waffle_solver

