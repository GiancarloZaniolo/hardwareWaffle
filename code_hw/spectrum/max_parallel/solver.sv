/*

This file contains the implementation for a minimum latency wafflelab solver

It is purely combinational

*/

`default_nettype none

// NOTE: This solves entirely combinationally lol
// For development speed, we hard-case on the IMG_ROWS-IMG_COLS dim


module waffle_solver
  #(parameter IMG_ROWS=2, parameter IMG_COLS=4)
  (input logic [IMG_ROWS-1:0] [IMG_COLS-1:0] [31:0] memory_input,
  output logic [31:0] result);
  
  // Prefix sums
  logic [IMG_ROWS-1:0] [IMG_COLS:0] [31:0] prefix_sums;

  genvar i;
  genvar j;
  generate
    for(i = 0; i < IMG_ROWS; i++) begin : row_iter_p
      for(j = 0; j <= IMG_COLS; j++) begin : col_iter_p
        if(j == 0) begin
          assign prefix_sums[i][j] = 32'd0;
        end else begin
          assign prefix_sums[i][j] = memory_input[i][j-1] + prefix_sums[i][j-1];
        end
      end
    end
  endgenerate

  // Create Column pair differences
  logic [IMG_COLS:0] [IMG_COLS:0] [IMG_ROWS-1:0] [31:0] col_diffs;


  genvar k;
  generate
    for(i = 0; i < IMG_ROWS; i++) begin: row_iter_d
      for(j = 0; j <= IMG_COLS; j++) begin: col_iter1_d
        for(k = j; k <= IMG_COLS; k++) begin: col_iter2_d
          assign col_diffs[j][k][i] = prefix_sums[i][k] - prefix_sums[i][j];
        end
      end
    end
  endgenerate


  // Perform MCSS reduction

  // [column_comb start idx] [column_comb end idx]
  // [layer of mcss] [idx of mcsss row] tuple (mcss, max_prefix, max_suffix, total)
  logic [IMG_COLS:0] [IMG_COLS:0] [$clog2(IMG_ROWS):0] [IMG_ROWS-1:0] [3:0] [31:0] mcss_temp;

  function logic [31:0] max2(logic [31:0] x, logic [31:0] y);
    return ($signed(x) > $signed(y)) ? x : y;
  endfunction: max2

  function logic [31:0] max3(logic [31:0] x, logic [31:0] y, logic [31:0] z);
    return max2(x,max2(y,z));
  endfunction: max3


  genvar l;
  generate
    for(i = 0; i <= IMG_COLS; i++) begin: col_iter1_r
      for(j = i; j <= IMG_COLS; j++) begin: col_iter2_r
        // Assign initial values in mcss
        for(l = 0; l < IMG_ROWS; l++) begin: row_init_r
          always_comb begin
            mcss_temp[i][j][0][l][0] = col_diffs[i][j][l];
            mcss_temp[i][j][0][l][1] = col_diffs[i][j][l];
            mcss_temp[i][j][0][l][2] = col_diffs[i][j][l];
            mcss_temp[i][j][0][l][3] = col_diffs[i][j][l];
          end
        end

        for(k = 1; k <= $clog2(IMG_ROWS); k++) begin: mcss_iter_r
          for(l = 0; l < (IMG_ROWS >> (k-1)); l = l + 2) begin: mcss_row_r
            always_comb begin
              // mcss
              mcss_temp[i][j][k][l>>1][0] = max3((mcss_temp[i][j][k-1][l][2]+mcss_temp[i][j][k-1][l+1][1]), mcss_temp[i][j][k-1][l][0], mcss_temp[i][j][k-1][l+1][0]);
              // prefix
              mcss_temp[i][j][k][l>>1][1] = max2(mcss_temp[i][j][k-1][l][1], (mcss_temp[i][j][k-1][l][3] + mcss_temp[i][j][k-1][l+1][1]));
              // suffix
              mcss_temp[i][j][k][l>>1][2] = max2(mcss_temp[i][j][k-1][l+1][2], (mcss_temp[i][j][k-1][l][2] + mcss_temp[i][j][k-1][l+1][3]));
              // total
              mcss_temp[i][j][k][l>>1][3] = mcss_temp[i][j][k-1][l][3] + mcss_temp[i][j][k-1][l+1][3];
            end
          end
        end
      end
    end
  endgenerate

  // Perform final reduction

  // First stage, down one set of columns
  // [column_comb start idx] [layer of reduction] [column_comb end idx]
  logic [IMG_COLS:0] [$clog2(IMG_COLS)+1:0] [IMG_COLS:0] [31:0] reduce_dim1_temp;

  generate
    for(i = 0; i <= IMG_COLS; i++) begin: col_iter1_r2
      // Assign initial values in reduction
      for(j = i; j <= IMG_COLS; j++) begin: col_iter2_r2
        assign reduce_dim1_temp[i][0][j] = mcss_temp[i][j][$clog2(IMG_ROWS)][0][0];
      end

      for(j = 1; j <= $clog2(IMG_COLS)+1; j++) begin: reduce_iter_r
        for(k = 0; k <= (IMG_COLS >> (j-1)); k = k + 2) begin: reduce_col_r 
          if(k == (IMG_COLS>>(j-1))) begin
            assign reduce_dim1_temp[i][j][k>>1] = reduce_dim1_temp[i][j-1][k];
          end else if(k >= (i>>(j-1))) begin
            assign reduce_dim1_temp[i][j][k>>1] = max2(reduce_dim1_temp[i][j-1][k], reduce_dim1_temp[i][j-1][k+1]);
          end else if(k+1 == (i>>(j-1))) begin
            assign reduce_dim1_temp[i][j][k>>1] = reduce_dim1_temp[i][j-1][k+1];
          end
        end
      end
    end
  endgenerate


  // Second stage, down other set of columns
  // [layer of reduction] [column_comb start idx]
  logic [$clog2(IMG_COLS)+1:0] [IMG_COLS:0] [31:0] reduce_dim2_temp;
        
  generate 
    for(i = 0; i <= IMG_COLS; i++) begin: col_iter1_r3
      assign reduce_dim2_temp[0][i] = reduce_dim1_temp[i][$clog2(IMG_COLS)+1][0];
    end

    for(i = 1; i <= $clog2(IMG_COLS)+1; i++) begin: reduce_iter2_r
      for(j = 0; j <= (IMG_COLS >> (i-1)); j = j + 2) begin: reduce_col2_r
        if(j == (IMG_COLS >> (i-1))) begin
          assign reduce_dim2_temp[i][j>>1] = reduce_dim2_temp[i-1][j];
        end else begin
          assign reduce_dim2_temp[i][j>>1] = max2(reduce_dim2_temp[i-1][j],reduce_dim2_temp[i-1][j+1]);
        end
      end
    end
  endgenerate

  assign result = reduce_dim2_temp[$clog2(IMG_COLS)][0];


endmodule: waffle_solver

