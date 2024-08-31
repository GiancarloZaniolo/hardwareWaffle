`default_nettype none

// 7 Segment display module
module SevenSegmentDisplay
(input logic [3:0] BCD7, BCD6, BCD5, BCD4, BCD3, BCD2, BCD1, BCD0,
input logic [7:0] blank,
output logic [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

logic [6:0] preHEX7,preHEX6,preHEX5,preHEX4,preHEX3,preHEX2,preHEX1,preHEX0,
pre2HEX7,pre2HEX6,pre2HEX5,pre2HEX4,pre2HEX3,pre2HEX2,pre2HEX1,pre2HEX0;

BCDtoSevenSegment digit7(.bcd(BCD7),.segment(preHEX7));
BCDtoSevenSegment digit6(.bcd(BCD6),.segment(preHEX6));
BCDtoSevenSegment digit5(.bcd(BCD5),.segment(preHEX5));
BCDtoSevenSegment digit4(.bcd(BCD4),.segment(preHEX4));
BCDtoSevenSegment digit3(.bcd(BCD3),.segment(preHEX3));
BCDtoSevenSegment digit2(.bcd(BCD2),.segment(preHEX2));
BCDtoSevenSegment digit1(.bcd(BCD1),.segment(preHEX1));
BCDtoSevenSegment digit0(.bcd(BCD0),.segment(preHEX0));

Mux2to1 isBlanked7(.I0(preHEX7),.I1(7'd0),.S(blank[7]),.Y(pre2HEX7));
Mux2to1 isBlanked6(.I0(preHEX6),.I1(7'd0),.S(blank[6]),.Y(pre2HEX6));
Mux2to1 isBlanked5(.I0(preHEX5),.I1(7'd0),.S(blank[5]),.Y(pre2HEX5));
Mux2to1 isBlanked4(.I0(preHEX4),.I1(7'd0),.S(blank[4]),.Y(pre2HEX4));
Mux2to1 isBlanked3(.I0(preHEX3),.I1(7'd0),.S(blank[3]),.Y(pre2HEX3));
Mux2to1 isBlanked2(.I0(preHEX2),.I1(7'd0),.S(blank[2]),.Y(pre2HEX2));
Mux2to1 isBlanked1(.I0(preHEX1),.I1(7'd0),.S(blank[1]),.Y(pre2HEX1));
Mux2to1 isBlanked0(.I0(preHEX0),.I1(7'd0),.S(blank[0]),.Y(pre2HEX0));

assign HEX7 = ~pre2HEX7;
assign HEX6 = ~pre2HEX6;
assign HEX5 = ~pre2HEX5;
assign HEX4 = ~pre2HEX4;
assign HEX3 = ~pre2HEX3;
assign HEX2 = ~pre2HEX2;
assign HEX1 = ~pre2HEX1;
assign HEX0 = ~pre2HEX0;

endmodule: SevenSegmentDisplay

// BCD to 7 segment module
module BCDtoSevenSegment
(input logic [3:0] bcd,
output logic [6:0] segment);

always_comb begin
    segment[0] = 1'b1;
    segment[1] = 1'b1;
    segment[2] = 1'b1;
    segment[3] = 1'b1;
    segment[4] = 1'b1;
    segment[5] = 1'b1;
    segment[6] = 1'b1;
    
    if(bcd == 4'd0) begin
        segment[6] = 1'b0;
    end else if (bcd == 4'd1) begin
        segment[0] = 1'b0;
        segment[3] = 1'b0;
        segment[4] = 1'b0;
        segment[5] = 1'b0;
        segment[6] = 1'b0;
    end else if (bcd == 4'd2) begin
        segment[2] = 1'b0;
        segment[5] = 1'b0;
    end else if (bcd == 4'd3) begin
        segment[4] = 1'b0;
        segment[5] = 1'b0;
    end else if (bcd == 4'd4) begin
        segment[0] = 1'b0;
        segment[3] = 1'b0;
        segment[4] = 1'b0;
    end else if (bcd == 4'd5) begin
        segment[1] = 1'b0;
        segment[4] = 1'b0;
    end else if (bcd == 4'd6) begin
        segment[1] = 1'b0;
    end else if (bcd == 4'd7) begin
        segment[3] = 1'b0;
        segment[4] = 1'b0;
        segment[5] = 1'b0;
        segment[6] = 1'b0;
    end else if (bcd == 4'd9) begin
        segment[4] = 1'b0;
    end

end

endmodule: BCDtoSevenSegment
