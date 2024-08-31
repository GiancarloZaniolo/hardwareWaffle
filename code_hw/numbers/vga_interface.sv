`default_nettype none

// TODO it would be based if I were to modify this to support aritrarily sized 
//  VGA displays and then had a bunch of macros defining the screen size, but
//  alas I am too lazy

module vga
    (input logic CLOCK_50, reset,
     output logic HS, VS, blank,
     output logic [8:0] row,
     output logic [9:0] col);

    logic [11:0] countHS;
    logic [10:0] vsClk;
    logic loadHS, loadVS;
    logic hor_valid, ver_valid;

    assign loadHS = countHS == 12'd1599;

    assign loadVS = (vsClk == 11'd520) && loadHS;

    // Counter, sets to 'd on .load(), else +1 on enable
    CounterTwo #(12) hsC(.D(12'd0), .en(1'b1), .clear(reset), .load(loadHS),
        .clock(CLOCK_50), .up(1'b1), .Q(countHS));
    CounterTwo #(11) vsNextClk(.D(11'd0),.en(loadHS),.clear(reset),.load(loadVS),
        .clock(CLOCK_50),.up(1'b1),.Q(vsClk));

    assign col = (countHS>>1) - 10'd144;
    assign row = vsClk - 9'd30;

    //range checks based on current values
    range_check #(12) hs(.low(12'd192), .high(12'd1599),
                         .val(countHS), .is_between(HS));

    range_check #(11) vs(.low(11'd2), .high(11'd520),
                         .val(vsClk), .is_between(VS));



    range_check #(12) HSrange(.low(12'd288), .high(12'd1566),
                        .val(countHS), .is_between(hor_valid));

    range_check #(11) VSrange(.low(11'd31), .high(11'd509),
                        .val(vsClk), .is_between(ver_valid));

    assign blank = ~(hor_valid & ver_valid);

endmodule: vga

// Custom asynchronous counter
module CounterTwo
  #(parameter WIDTH=8)
  (input  logic [WIDTH-1:0] D,
   input  logic             en, clear, load, clock, up,
   output logic [WIDTH-1:0] Q);

  always_ff @(posedge clock, posedge clear)
    if (clear)
      Q <= {WIDTH {1'b0}};
    else if (load)
      Q <= D;
    else if (en)
      if (up)
        Q <= Q + 1'b1;
      else
        Q <= Q - 1'b1;

endmodule : CounterTwo

// Test for VGA driver
module vga_test;
    logic CLOCK_50, reset;
    logic HS, VS, blank;
    logic [8:0] row;
    logic [9:0] col;

    vga dut(.*);

    initial begin
        CLOCK_50 = 0;
        forever #1 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        reset = 1;
        #5;
        reset <= 0;
        #5
        reset = 1;
        #5;
        reset <= 0;
        #5
        reset = 1;
        #5;
        reset <= 0;
        #5

        #5000000 $finish;
    end
endmodule: vga_test