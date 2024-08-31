`default_nettype none
module FAST_WAFFLE (
          input logic clk, rst_l,
          output logic last_inputs,
          output logic [31:0] waffle_val);
  
  logic wren_a, wren_b, first_part;
  logic [8:0] address_a, address_b;
  logic [31:0] temp_waffle_val, mcss_val;
  logic [255:0][31:0] input_vals;
  logic [255:0][31:0] sum_temp, diff_temp, a_val;

  logic [255:0][31:0] data_a, data_b, q_a, q_b;
  localparam string mifs[256] = 
  '{ 
    "bram_0.mif",
    "bram_1.mif",
    "bram_2.mif",
    "bram_3.mif",
    "bram_4.mif",
    "bram_5.mif",
    "bram_6.mif",
    "bram_7.mif",
    "bram_8.mif",
    "bram_9.mif",
    "bram_10.mif",
    "bram_11.mif",
    "bram_12.mif",
    "bram_13.mif",
    "bram_14.mif",
    "bram_15.mif",
    "bram_16.mif",
    "bram_17.mif",
    "bram_18.mif",
    "bram_19.mif",
    "bram_20.mif",
    "bram_21.mif",
    "bram_22.mif",
    "bram_23.mif",
    "bram_24.mif",
    "bram_25.mif",
    "bram_26.mif",
    "bram_27.mif",
    "bram_28.mif",
    "bram_29.mif",
    "bram_30.mif",
    "bram_31.mif",
    "bram_32.mif",
    "bram_33.mif",
    "bram_34.mif",
    "bram_35.mif",
    "bram_36.mif",
    "bram_37.mif",
    "bram_38.mif",
    "bram_39.mif",
    "bram_40.mif",
    "bram_41.mif",
    "bram_42.mif",
    "bram_43.mif",
    "bram_44.mif",
    "bram_45.mif",
    "bram_46.mif",
    "bram_47.mif",
    "bram_48.mif",
    "bram_49.mif",
    "bram_50.mif",
    "bram_51.mif",
    "bram_52.mif",
    "bram_53.mif",
    "bram_54.mif",
    "bram_55.mif",
    "bram_56.mif",
    "bram_57.mif",
    "bram_58.mif",
    "bram_59.mif",
    "bram_60.mif",
    "bram_61.mif",
    "bram_62.mif",
    "bram_63.mif",
    "bram_64.mif",
    "bram_65.mif",
    "bram_66.mif",
    "bram_67.mif",
    "bram_68.mif",
    "bram_69.mif",
    "bram_70.mif",
    "bram_71.mif",
    "bram_72.mif",
    "bram_73.mif",
    "bram_74.mif",
    "bram_75.mif",
    "bram_76.mif",
    "bram_77.mif",
    "bram_78.mif",
    "bram_79.mif",
    "bram_80.mif",
    "bram_81.mif",
    "bram_82.mif",
    "bram_83.mif",
    "bram_84.mif",
    "bram_85.mif",
    "bram_86.mif",
    "bram_87.mif",
    "bram_88.mif",
    "bram_89.mif",
    "bram_90.mif",
    "bram_91.mif",
    "bram_92.mif",
    "bram_93.mif",
    "bram_94.mif",
    "bram_95.mif",
    "bram_96.mif",
    "bram_97.mif",
    "bram_98.mif",
    "bram_99.mif",
    "bram_100.mif",
    "bram_101.mif",
    "bram_102.mif",
    "bram_103.mif",
    "bram_104.mif",
    "bram_105.mif",
    "bram_106.mif",
    "bram_107.mif",
    "bram_108.mif",
    "bram_109.mif",
    "bram_110.mif",
    "bram_111.mif",
    "bram_112.mif",
    "bram_113.mif",
    "bram_114.mif",
    "bram_115.mif",
    "bram_116.mif",
    "bram_117.mif",
    "bram_118.mif",
    "bram_119.mif",
    "bram_120.mif",
    "bram_121.mif",
    "bram_122.mif",
    "bram_123.mif",
    "bram_124.mif",
    "bram_125.mif",
    "bram_126.mif",
    "bram_127.mif",
    "bram_128.mif",
    "bram_129.mif",
    "bram_130.mif",
    "bram_131.mif",
    "bram_132.mif",
    "bram_133.mif",
    "bram_134.mif",
    "bram_135.mif",
    "bram_136.mif",
    "bram_137.mif",
    "bram_138.mif",
    "bram_139.mif",
    "bram_140.mif",
    "bram_141.mif",
    "bram_142.mif",
    "bram_143.mif",
    "bram_144.mif",
    "bram_145.mif",
    "bram_146.mif",
    "bram_147.mif",
    "bram_148.mif",
    "bram_149.mif",
    "bram_150.mif",
    "bram_151.mif",
    "bram_152.mif",
    "bram_153.mif",
    "bram_154.mif",
    "bram_155.mif",
    "bram_156.mif",
    "bram_157.mif",
    "bram_158.mif",
    "bram_159.mif",
    "bram_160.mif",
    "bram_161.mif",
    "bram_162.mif",
    "bram_163.mif",
    "bram_164.mif",
    "bram_165.mif",
    "bram_166.mif",
    "bram_167.mif",
    "bram_168.mif",
    "bram_169.mif",
    "bram_170.mif",
    "bram_171.mif",
    "bram_172.mif",
    "bram_173.mif",
    "bram_174.mif",
    "bram_175.mif",
    "bram_176.mif",
    "bram_177.mif",
    "bram_178.mif",
    "bram_179.mif",
    "bram_180.mif",
    "bram_181.mif",
    "bram_182.mif",
    "bram_183.mif",
    "bram_184.mif",
    "bram_185.mif",
    "bram_186.mif",
    "bram_187.mif",
    "bram_188.mif",
    "bram_189.mif",
    "bram_190.mif",
    "bram_191.mif",
    "bram_192.mif",
    "bram_193.mif",
    "bram_194.mif",
    "bram_195.mif",
    "bram_196.mif",
    "bram_197.mif",
    "bram_198.mif",
    "bram_199.mif",
    "bram_200.mif",
    "bram_201.mif",
    "bram_202.mif",
    "bram_203.mif",
    "bram_204.mif",
    "bram_205.mif",
    "bram_206.mif",
    "bram_207.mif",
    "bram_208.mif",
    "bram_209.mif",
    "bram_210.mif",
    "bram_211.mif",
    "bram_212.mif",
    "bram_213.mif",
    "bram_214.mif",
    "bram_215.mif",
    "bram_216.mif",
    "bram_217.mif",
    "bram_218.mif",
    "bram_219.mif",
    "bram_220.mif",
    "bram_221.mif",
    "bram_222.mif",
    "bram_223.mif",
    "bram_224.mif",
    "bram_225.mif",
    "bram_226.mif",
    "bram_227.mif",
    "bram_228.mif",
    "bram_229.mif",
    "bram_230.mif",
    "bram_231.mif",
    "bram_232.mif",
    "bram_233.mif",
    "bram_234.mif",
    "bram_235.mif",
    "bram_236.mif",
    "bram_237.mif",
    "bram_238.mif",
    "bram_239.mif",
    "bram_240.mif",
    "bram_241.mif",
    "bram_242.mif",
    "bram_243.mif",
    "bram_244.mif",
    "bram_245.mif",
    "bram_246.mif",
    "bram_247.mif",
    "bram_248.mif",
    "bram_249.mif",
    "bram_250.mif",
    "bram_251.mif",
    "bram_252.mif",
    "bram_253.mif",
    "bram_254.mif",
    "bram_255.mif"
  };
  genvar i;
  
  generate
    for(i = 0; i < 256; i = i + 1) begin :gen2
      assign data_a[i] = 32'b0;
      
      //assign sum_temp[i] = q_a[i] + data_b[i];
      //assign diff_temp[i] = q_b[i] - q_a[i];
      lpm_add la(
        .add_sub(first_part),
        .dataa(a_val[i]),
        .datab(q_a[i]),
        .result(sum_temp[i]));
      Register #(32) reg_inst_gen(.D(sum_temp[i]), .en(wren_b), .reset_n(rst_l), .clock(clk), .Q(data_b[i]));
      
      bram_fast #(mifs[i]) b(.clock(clk), 
                  .address_a, 
                  .address_b,
                  .wren_a,
                  .wren_b,
                  .data_a(data_a[i]),
                  .data_b(data_b[i]),
                  .q_a(q_a[i]),
                  .q_b(q_b[i]));
      
    end
  endgenerate

  assign first_part = (address_a == address_b || wren_b || address_b == 9'h1);
  assign temp_waffle_val = ($signed(waffle_val) > $signed(mcss_val)) ? waffle_val : mcss_val;
  assign input_vals = first_part ? data_b : sum_temp;
  assign a_val = first_part ? data_b : q_b;

  
  Port_A_Controller pa(.address_a, .wren_a, .address_b, .rst_l, .clk, .last_inputs);
  Port_B_Controller pb(.address_b, .wren_b, .last_inputs, .address_a, .rst_l, .clk);
  MCSS mc(.input_vals, .clk, .rst_l, .mcss_val);
  Register #(32) reg_inst(.D(temp_waffle_val), .en(1'b1), .reset_n(rst_l), .clock(clk), .Q(waffle_val));


endmodule: FAST_WAFFLE
module Register
  #(parameter WIDTH=8)
  (input  logic [WIDTH-1:0] D,
   input  logic             en, reset_n, clock,
   output logic [WIDTH-1:0] Q);
   
  always_ff @(posedge clock, negedge reset_n)
    if (~reset_n)
      Q <= '0;
    else if (en)
      Q <= D;
      
endmodule : Register


//implicitly starts cycle after rst_l is deasserted
module Port_A_Controller
  (output logic [8:0] address_a,
   output logic wren_a,
   input logic [8:0] address_b,
   input logic rst_l, clk, last_inputs);
   logic [8:0] to_be_address_a;
   assign wren_a = 1'b0;
   always_ff @(posedge clk, negedge rst_l) begin
    if(~rst_l) begin
      address_a <= 9'b0;
      to_be_address_a <= 9'b0;
    end
    else if(last_inputs) begin
      //do nothing
    end
    else if(address_b == 9'h1FF) begin
      address_a <= to_be_address_a;
      to_be_address_a <= to_be_address_a + 9'b1;
    end
    else if(to_be_address_a == 9'b0) begin
      address_a <= address_a + 9'b1;
    end

   end

endmodule : Port_A_Controller

module Port_B_Controller
  (output logic [8:0] address_b,
   output logic wren_b, last_inputs,
   input logic [8:0] address_a,
   input logic rst_l, clk);
   logic [8:0] to_be_address_b;
   assign last_inputs = (address_b == 9'h1FF) && (to_be_address_b == 9'h1FF);
   assign wren_b = (address_a != address_b) && (to_be_address_b == 9'b0);
   always_ff @(posedge clk, negedge rst_l) begin
    if(~rst_l) begin
      address_b <= 9'b0;
      to_be_address_b <= 9'b0;
    end
    else if (last_inputs) begin
      //do nothing
    end
    else begin
      if(address_b == 9'h1FF) begin
        address_b <= to_be_address_b + 9'b1;
        to_be_address_b <= to_be_address_b + 9'b1;
      end
      else if(address_a == 9'b0 && address_b == 9'b0) begin
        //nothing
      end
      else begin
        address_b <= address_b + 9'b1;
      end
    end

   end

endmodule : Port_B_Controller