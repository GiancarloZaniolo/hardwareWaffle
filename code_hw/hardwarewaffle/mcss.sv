`default_nettype none
//MAKES ASSUMPTIONS THAT THERE IS NO OVERFLOW

// precondition parameters powers of 2, ROWS is at least 2
module MCSS #(parameter DATA_WIDTH=32, parameter ROWS=256) (input logic [(ROWS-1):0][(DATA_WIDTH-1):0] input_vals,
                                                            input logic clk, rst_l,
                                                            output logic [(DATA_WIDTH-1):0] mcss_val);
  logic [(ROWS-1):0][(DATA_WIDTH-1):0] m_vals, p_vals, s_vals, t_vals;
  genvar i, j;
  generate
    

    for(i = ROWS >> 1; i >= 1; i = i >> 1) begin : gen1
      localparam ind_base_prev = ROWS - (i << 2);
      localparam ind_base_cur = ROWS - (i << 1);
      for(j = 0; j < i; j = j + 1) begin : genj
        if(i == (ROWS >> 1)) begin
          BASE_CASE b(.clk, 
                    .rst_l, 
                    .a(input_vals[2 * j]), 
                    .b(input_vals[2 * j + 1]), 
                    .m(m_vals[j]),
                    .p(p_vals[j]), 
                    .s(s_vals[j]), 
                    .t(t_vals[j]));
        end
        else begin
          REDUCE_CASE r(.clk, 
                    .rst_l, 
                    .m1(m_vals[ind_base_prev + 2 * j]),
                    .p1(p_vals[ind_base_prev + 2 * j]), 
                    .s1(s_vals[ind_base_prev + 2 * j]), 
                    .t1(t_vals[ind_base_prev + 2 * j]),
                    .m2(m_vals[ind_base_prev + 2 * j + 1]),
                    .p2(p_vals[ind_base_prev + 2 * j + 1]), 
                    .s2(s_vals[ind_base_prev + 2 * j + 1]), 
                    .t2(t_vals[ind_base_prev + 2 * j + 1]),
                    .m(m_vals[ind_base_cur + j]),
                    .p(p_vals[ind_base_cur + j]), 
                    .s(s_vals[ind_base_cur + j]), 
                    .t(t_vals[ind_base_cur + j]));

        end
      end
    end
  endgenerate  
  assign mcss_val = m_vals[ROWS-2];                                       

endmodule: MCSS

/*
Sequential deep pipelined version
*/
module MCSS_DEEP #(parameter DATA_WIDTH=32, parameter ROWS=256) (input logic [(ROWS-1):0][(DATA_WIDTH-1):0] input_vals,
                                                            input logic clk, rst_l,
                                                            output logic [(DATA_WIDTH-1):0] mcss_val);
  logic [(ROWS-1):0][(ROWS-1):0][(DATA_WIDTH-1):0] all_wires;
  logic [(ROWS-1):0][(DATA_WIDTH-1):0] max_so_far_temp, max_ending_here_temp, max_so_far, max_ending_here;
  genvar i, j;
  generate
    assign all_wires[0] = input_vals;
    for(i = 0; i < ROWS; i = i + 1) begin : gendeep
      for(j = i; j < ROWS; j = j + 1) begin : gendeepreg
        if(j == i) begin
          always_comb begin
            max_so_far_temp[i] = {DATA_WIDTH{1'b0}};
            max_ending_here_temp[i] = {DATA_WIDTH{1'b0}};
            if(i > 0) begin
              if(!(max_ending_here[i - 1] + all_wires[i][i])[DATA_WIDTH-1]) begin
                max_ending_here_temp[i] = max_ending_here[i - 1] + all_wires[i][i];
              end
              max_so_far_temp[i] = max_so_far[i - 1];
              if($signed(max_so_far[i - 1]) < $signed(max_ending_here_temp[i])) begin
                max_so_far_temp[i] = max_ending_here_temp[i];
              end
            end
            else begin
              if(!all_wires[i][i][DATA_WIDTH - 1]) begin
                max_ending_here_temp[i] = all_wires[i][i];
              end
              max_so_far_temp[i] = max_ending_here_temp[i];
            end
          end
          Register #(DATA_WIDTH) (.D(max_so_far_temp[i]), .en(1'b1), .reset_n(rst_l), .clock(clk), .Q(max_so_far[i]));
          Register #(DATA_WIDTH) (.D(max_ending_here_temp[i]), .en(1'b1), .reset_n(rst_l), .clock(clk), .Q(max_ending_here[i]));

        end
        else begin
          if(i > 0) begin
            Register #(DATA_WIDTH) (.D(all_wires[i - 1][j]), .en(1'b1), .reset_n(rst_l), .clock(clk), .Q(all_wires[i][j]));

          end
        end

      end
    end
  endgenerate  
  assign mcss_val = max_so_far[ROWS-1];                                       

endmodule: MCSS_DEEP

module BASE_CASE #(parameter DATA_WIDTH=32) (input logic [(DATA_WIDTH - 1):0] a, b,
                                             input logic clk, rst_l,
                                              output logic [(DATA_WIDTH - 1):0] m, p, s, t);
  logic [(DATA_WIDTH - 1):0] m_temp, p_temp, s_temp, t_temp;
  logic [(DATA_WIDTH - 1):0] ab;
  logic [1:0] sel;
  assign sel = {a[DATA_WIDTH-1], b[DATA_WIDTH-1]};
  mux_4 mm(
	.data0x(ab),
	.data1x(a),
	.data2x(b),
	.data3x({DATA_WIDTH{1'b0}}),
	.sel,
	.result(m_temp));
  mux_4 mp(
	.data0x(ab),
	.data1x(a),
	.data2x(ab[DATA_WIDTH-1] ? 0 : ab),
	.data3x({DATA_WIDTH{1'b0}}),
	.sel,
	.result(p_temp));
  mux_4 ms(
	.data0x(ab),
	.data1x(ab[DATA_WIDTH-1] ? 0 : ab),
	.data2x(b),
	.data3x({DATA_WIDTH{1'b0}}),
	.sel,
	.result(s_temp));

  /*
    m = a > 0 then  (b > 0 then a + b else a) else (b  > 0 then b else 0)
    p = a > 0 then (b > 0 then a + b else a) else (a + b > 0 then a + b else 0) 
    s = a > 0 then (a + b > 0 then a + b else 0) else (b > 0 then b else 0)
    t = a + b
  */
  always_comb begin
    ab = a + b;
    t_temp = ab;
  end
 
  always_ff @(posedge clk, negedge rst_l) begin
    if(~rst_l) begin
        m <= {DATA_WIDTH{1'b0}};
        p <= {DATA_WIDTH{1'b0}};
        s <= {DATA_WIDTH{1'b0}};
        t <= {DATA_WIDTH{1'b0}};
    end
    else begin
        m <= m_temp;
        p <= p_temp;
        s <= s_temp;
        t <= t_temp;
    end
  end
endmodule: BASE_CASE

module REDUCE_CASE #(parameter DATA_WIDTH=32) (input logic [(DATA_WIDTH - 1):0] m1, p1, s1, t1, m2, p2, s2, t2,
                                               input logic clk, rst_l,
                                              output logic [(DATA_WIDTH - 1):0] m, p, s, t);
  logic [(DATA_WIDTH - 1):0] s1p2, s1p2m1, t1p2, t2s1;
  logic [(DATA_WIDTH - 1):0] m_temp, p_temp, s_temp, t_temp;

  always_comb begin
    s1p2 = s1 + p2;
    t1p2 = t1 + p2;
    t2s1 = t2 + s1;
    //without overflow, s1, p2, m1 are all non-negative
    s1p2m1 = (s1p2 > m1) ? s1p2 : m1;


    m_temp = (s1p2m1 > m2) ? s1p2m1 : m2;
    p_temp = (p1 > t1p2 || t1p2[DATA_WIDTH - 1]) ? p1 : t1p2;
    s_temp = (s2 > t2s1 || t2s1[DATA_WIDTH - 1]) ? s2 : t2s1;
    t_temp = t1 + t2;
  end
  always_ff @(posedge clk, negedge rst_l) begin
    if(~rst_l) begin
        m <= {DATA_WIDTH{1'b0}};
        p <= {DATA_WIDTH{1'b0}};
        s <= {DATA_WIDTH{1'b0}};
        t <= {DATA_WIDTH{1'b0}};
    end
    else begin
        m <= m_temp;
        p <= p_temp;
        s <= s_temp;
        t <= t_temp;
    end
  end
endmodule: REDUCE_CASE