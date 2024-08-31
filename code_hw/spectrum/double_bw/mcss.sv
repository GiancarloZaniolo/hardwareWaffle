

`default_nettype none

module mcss 
  #(parameter IMG_ROWS=4)
  (input logic en, rst, clk, 
  input logic [IMG_ROWS-1:0] [31:0] arr,
  output logic valid, empty,
  output logic [31:0] result);

  function logic [31:0] max2(logic [31:0] x, logic [31:0] y);
    return ($signed(x) > $signed(y)) ? x : y;
  endfunction: max2

  function logic [31:0] max3(logic [31:0] x, logic [31:0] y, logic [31:0] z);
    return max2(x,max2(y,z));
  endfunction: max3

  typedef struct {
    logic [31:0] mcss;
    logic [31:0] prefix; 
    logic [31:0] suffix; 
    logic [31:0] sum;
  } st_mcss;

  st_mcss mcss_stages [$clog2(IMG_ROWS):0] [IMG_ROWS-1:0] ;
  logic [$clog2(IMG_ROWS):0] layer_en;

  genvar i;
  genvar j;
  generate
  for(i = 0; i <= $clog2(IMG_ROWS); i++) begin: reduce_lvls
      if(i == 0) begin
        always_ff @(posedge clk, posedge rst) begin
          if(rst) begin
            layer_en[i] <= 0;
          end else begin
            layer_en[i] <= en;
          end
        end
        for(j = 0; j < IMG_ROWS; j++) begin
          always_ff @(posedge clk, posedge rst) begin
            if(rst) begin
              mcss_stages[i][j] <= '{0,0,0,0};
            end else begin
              mcss_stages[i][j] <= '{arr[j],arr[j],arr[j],arr[j]};
            end
          end
        end

      end else begin
        always_ff @(posedge clk, posedge rst) begin
          if(rst) begin
            layer_en[i] <= 0;
          end else begin
            layer_en[i] <= layer_en[i-1];
          end
        end
        for(j = 0; j < (IMG_ROWS >> (i-1)); j += 2) begin
          always_ff @(posedge clk, posedge rst) begin
            mcss_stages[i][j>>1].mcss <= 
              max3(
                mcss_stages[i-1][j].suffix + mcss_stages[i-1][j+1].prefix, 
                mcss_stages[i-1][j].mcss, 
                mcss_stages[i-1][j+1].mcss
              );
            mcss_stages[i][j>>1].prefix <=
              max2(
                mcss_stages[i-1][j].prefix,
                mcss_stages[i-1][j].sum + mcss_stages[i-1][j+1].prefix
              );
            mcss_stages[i][j>>1].suffix <= 
              max2(
                mcss_stages[i-1][j+1].suffix,
                mcss_stages[i-1][j].suffix + mcss_stages[i-1][j+1].sum
              );
            mcss_stages[i][j>>1].sum <= mcss_stages[i-1][j].sum + mcss_stages[i-1][j+1].sum;
          end
        end
      end
    end
  endgenerate

  logic [$clog2(IMG_ROWS):0] layer_empty;
  generate
    for(i = 0; i <= $clog2(IMG_ROWS); i++) begin: gen_empty
      if(i == 0) begin
        assign layer_empty[i] = layer_en[i];
      end else begin
        assign layer_empty[i] = layer_empty[i-1] || layer_en[i];
      end
    end
  endgenerate


  assign result = mcss_stages[$clog2(IMG_ROWS)][0].mcss;
  assign valid = layer_en[$clog2(IMG_ROWS)];
  assign empty = ~layer_empty[$clog2(IMG_ROWS)];


endmodule: mcss