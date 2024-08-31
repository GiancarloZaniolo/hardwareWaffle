/*

This file contains the implementation for a wafflelab solver that does mcss on
two columns at once.

*/

`default_nettype none

module waffle_solver
  #(parameter IMG_ROWS=4, parameter IMG_COLS=4)
  (input logic rst, clk,
  input logic [IMG_ROWS-1:0] [31:0] in_data1, in_data2,
  output logic we, complete,
  output logic [IMG_ROWS-1:0] [31:0] write_data,
  output logic [31:0] addr1, addr2, addr_write);


  function logic [31:0] max2(logic [31:0] x, logic [31:0] y);
    return ($signed(x) > $signed(y)) ? x : y;
  endfunction: max2

  // Do prefix and then output to preserve memory interface and have 
  //  implementation simplicity. Won't lose out on too many clock cycles.
  enum logic [1:0] {PREFIX_STEP,MCSS_STEP,COMPLETE} path_step; 
  assign complete = path_step == COMPLETE;

  // Prefix sum stage variables
  logic [$clog2(IMG_COLS):0] curr_col;

  logic [IMG_ROWS-1:0] [31:0] curr_acc, next_acc;
  logic [31:0] addr1_prefix, addr_write_prefix;
  logic [IMG_ROWS-1:0] [31:0] write_data_prefix;



  // MCSS and reduction stage variables
  logic [31:0] addr1_mcss, addr2_mcss;
  
  logic solv1_finished, solv2_finished;
  logic [31:0] solv1_best, solv2_best;

  logic [31:0] result;
  assign result = max2(solv1_best,solv2_best);


  // Sequential block for prefix step and complete condition
  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      curr_col <= 0;
      curr_acc <= 0;
      path_step <= PREFIX_STEP;
      we <= 1;
    end else begin
      if(path_step == PREFIX_STEP) begin
        if(curr_col >= (IMG_COLS-1)) begin
          path_step <= MCSS_STEP;
          curr_col <= 0;
          we <= 0;
        end else begin
          curr_col <= curr_col + 1;
          curr_acc <= next_acc;
        end
      end else begin
        if(solv1_finished && solv2_finished) begin
          path_step <= COMPLETE;
        end
      end
    end
  end

  // Combinational block for prefix step
  always_comb begin
    addr1_prefix = {{32-$clog2(IMG_COLS){1'd0}}, curr_col[$clog2(IMG_ROWS)-1:0]};
    addr_write_prefix = addr1_prefix;
    // NOTE: may overflow, idrc right now
    next_acc = curr_acc + in_data1;
    write_data_prefix = next_acc;
  end

  
  one_col_solver #(IMG_ROWS, IMG_COLS, -1) solv1(
    .rst, .clk, .en(path_step == MCSS_STEP), .finished(solv1_finished),
    .in_data(in_data1), .addr(addr1_mcss), .best(solv1_best));

  one_col_solver #(IMG_ROWS, IMG_COLS, -2) solv2(
    .rst, .clk, .en(path_step == MCSS_STEP), .finished(solv2_finished),
    .in_data(in_data2), .addr(addr2_mcss), .best(solv2_best));



  always_comb begin
    if(path_step == PREFIX_STEP) begin
      addr1 = addr1_prefix;
      addr_write = addr_write_prefix;
      write_data = write_data_prefix;
    end else if(path_step == MCSS_STEP) begin
      addr1 = addr1_mcss;
      addr2 = addr2_mcss; 
    end
  end


endmodule: waffle_solver


module one_col_solver
  #(parameter IMG_ROWS=4, parameter IMG_COLS=4, parameter START_IDX=0)
  (input logic rst, clk, en,
  input logic [IMG_ROWS-1:0] [31:0] in_data,
  output logic finished,
  output logic [31:0] addr,
  output logic [31:0] best);

  logic [31:0] curr_addr;
  logic [31:0] cache_addr, cache_addr_next;
  logic [IMG_ROWS-1:0] [31:0] cache, cache_next;

  logic [31:0] idx_requested;
  logic [$clog2(IMG_COLS)-1:0] idx_requested_dec1_bits;
  assign idx_requested_dec1_bits = idx_requested[$clog2(IMG_COLS)-1:0] - 1;

  logic [IMG_ROWS-1:0] [31:0] in_data_proc;
  assign in_data_proc = idx_requested == 0 ? 0 : in_data;

  // NOTE: mcss_en is 1 cycle delayed from when we actually want the mcss to 
  //  hold something, but this works out with respect to the computation because
  //  'best' also gets stuff 1 cycle later. Only negative side effect is 
  //  potentially 1 cycle slower to empty out.
  logic mcss_valid, mcss_en, mcss_empty;
  logic [IMG_ROWS-1:0] [31:0] curr_diff;
  // NOTE: this may overflow, idrc right now, cycles stay the same
  assign curr_diff = in_data_proc - cache;
  
  logic [31:0] mcss_res;
  mcss #(IMG_ROWS) mcss1(.rst, .clk, .en(mcss_en), .arr(curr_diff),
    .valid(mcss_valid), .result(mcss_res), .empty(mcss_empty));

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      cache_addr <= START_IDX;
      curr_addr <= IMG_COLS + 1;
      finished <= 0;
      best <= 0;

    end else begin
      if(en) begin
        if($signed(cache_addr) >= IMG_COLS) begin
          if(mcss_empty) begin
            finished <= 1;
          end
        end else begin
          cache <= cache_next;
          if(curr_addr > IMG_COLS) begin
            mcss_en <= 0;
            cache_addr <= cache_addr_next;
            curr_addr <= cache_addr_next;
          end else begin
            mcss_en <= 1;
            curr_addr <= curr_addr + 1;
          end
        end
        if(mcss_valid) begin
          best <= max2(best, mcss_res);
        end
      end

    end
  end

  always_comb begin
    if(curr_addr > IMG_COLS) begin
      cache_next = in_data_proc;
      if((cache_addr & 1) == 0) begin
        cache_addr_next = cache_addr + 3;
      end else begin
        cache_addr_next = cache_addr + 1;
      end
      idx_requested = cache_addr_next;
    end else begin
      cache_next = cache;
      idx_requested = curr_addr;
    end
    addr = {{32-$clog2(IMG_COLS){1'd0}}, idx_requested_dec1_bits};
  end


endmodule: one_col_solver

