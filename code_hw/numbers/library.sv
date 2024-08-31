`default_nettype none

// MagComp module
// n bit inputs (unsigned), returns if one is gt,lt,eq the other
module MagComp
#(parameter WIDTH = 8)
(input logic [WIDTH-1:0] A, B,
 output logic AltB, AeqB, AgtB);

assign AltB = A < B;
assign AeqB = A == B;
assign AgtB = A > B;

endmodule: MagComp

// Adder module
// n bit input and output with carry in and out
module Adder
#(parameter WIDTH = 8)
(input logic cin,
 input logic [WIDTH-1:0] A, B,
 output logic cout,
 output logic [WIDTH-1:0] S);

logic [WIDTH:0] sumBig;

assign sumBig = A + B + cin;
assign S = sumBig [WIDTH-1:0];
assign cout = sumBig [WIDTH];

endmodule: Adder

// Multiplexer module
// Takes in n bit input, selects one using log_2 n bit number to be passed to 
//    1-bit output
module Multiplexer
#(parameter WIDTH = 8)
(input logic [WIDTH-1:0] I,
 input logic [$clog2(WIDTH)-1:0] S,
 output logic Y);

assign Y = I[S];

endmodule: Multiplexer

// Mux2to1 module
// Takes in two n-bit inputs and a select, outputs appropriate n bit number
module Mux2to1
#(parameter WIDTH = 8)
(input logic [WIDTH-1:0] I0, I1,
 input logic S,
 output logic [WIDTH-1:0] Y);

assign Y = S ? I1 : I0;

endmodule: Mux2to1

// Decoder module
// log_2 n bit input, "enable"s one of n output bits
module Decoder
#(parameter WIDTH = 8)
(input logic [$clog2(WIDTH)-1:0] I,
 input logic en,
 output logic [WIDTH-1:0] D);

always_comb begin
    D = 0;
    D[I] = en;
end

endmodule: Decoder

// DFlipFlop module
// D-flip flop with preset and reset
module DFlipFlop
(input logic preset_L, reset_L, clock, D,
 output logic Q);

always_ff @(posedge clock, negedge preset_L, negedge reset_L) begin
    if (~reset_L)
        Q <= 0;
    else if (~preset_L)
        Q <= 1;
    else
        Q <= D;
end

endmodule: DFlipFlop

// Register Module
// Register with enable and clear
// Priority: enable > clear
module Register
#(parameter WIDTH = 8)
(input logic en, clear, clock,
 input logic [WIDTH-1:0] D,
 output logic [WIDTH-1:0] Q);

logic [WIDTH-1:0] ffIn;

always_comb begin
    if(en)
        ffIn = D;
    else if(clear)
        ffIn = 0;
    else
        ffIn = Q;
end

always_ff @(posedge clock) begin
    Q <= ffIn;
end

endmodule: Register

// Counter Module
// Counter with enable for clear, load, up, down(if up is 0)
// Priority: clear > load > up/down
// If ~enable, preserve value
module Counter
#(parameter WIDTH = 8)
(input logic en, clear, load, up, clock,
 input logic [WIDTH-1:0] D,
 output logic [WIDTH-1:0] Q);

logic [WIDTH-1:0] ffIn;

always_comb begin
    if(en) begin
        if(clear)
            ffIn = 0;
        else if (load)
            ffIn = D;
        else if(up)
            ffIn = Q+1;
        else 
            ffIn = Q-1;
    end else
        ffIn = Q;
end

always_ff @(posedge clock) begin
    Q <= ffIn;
end

endmodule: Counter

// Synchronizer module
// 2 flip flops in a row synchronize asynchronous inputs in relation to the
//    clock
module Synchronizer
(input logic async, clock,
 output logic sync);

logic peereset_L, intermediate;

assign peereset_L = 1;

DFlipFlop f1(.D(async),.Q(intermediate),.clock,.preset_L(peereset_L),
    .reset_L(peereset_L)),
          f2(.D(intermediate),.Q(sync),.clock,.preset_L(peereset_L),
    .reset_L(peereset_L));

endmodule: Synchronizer

// ShiftRegister_SIPO module
// Takes in serial input and enable and exports in parallel
// Took bit is MSB or LSB depending on shift direction
module ShiftRegister_SIPO
#(parameter WIDTH = 8)
(input logic serial, en, left, clock,
 output logic [WIDTH-1:0] Q);

logic [WIDTH-1:0] D;
logic clear;

Register #(WIDTH) reggie(.D,.Q,.en,.clock,.clear);

assign clear = 0;

always_comb begin
    if(en)
        if(left)
            D = (Q << 1) | serial;
        else begin
            D = Q >> 1;
            D[WIDTH-1] = serial;
        end
    else
        D = Q;
end

endmodule: ShiftRegister_SIPO

// ShiftRegister_PIPO module
// Takes in parallel input, shifts when enable and not load
module ShiftRegister_PIPO
#(parameter WIDTH = 8)
(input logic en, left, load, clock,
 input logic [WIDTH-1:0] D,
 output logic [WIDTH-1:0] Q);

logic clear, regEn;
logic [WIDTH-1:0] regInput;

Register #(WIDTH) reggie(.D(regInput),.Q,.en(regEn),.clock,.clear);

assign clear = 0;
assign regEn = 1;

always_comb begin
    if(load)
        regInput = D;
    else if(en)
        if(left)
            regInput = Q << 1;
        else
            regInput = Q >> 1;
    else
        regInput = Q;
end

endmodule: ShiftRegister_PIPO

// BarrelShiftRegister module
// Shifts left by a chosen number of bits
// Priority: load > shift
module BarrelShiftRegister
#(parameter WIDTH = 8)
(input logic en, load, clock,
 input logic [1:0] by,
 input logic [WIDTH-1:0] D,
 output logic [WIDTH-1:0] Q);

logic clear, regEn;
logic [WIDTH-1:0] regInput;

Register #(WIDTH) reggie(.D(regInput),.Q,.en(regEn),.clock,.clear);

assign clear = 0;
assign regEn = 1;

always_comb begin
    if(load)
        regInput = D;
    else if(en)
        regInput = Q << by;
    else
        regInput = Q;
end

endmodule: BarrelShiftRegister

// BusDriver module
// When enabled, val driven to bus, otherwise nothing
module BusDriver
#(parameter WIDTH = 8)
(input logic en,
 input logic [WIDTH-1:0] data,
 output logic [WIDTH-1:0] buff,
 inout tri [WIDTH-1:0] bus);

assign buff = bus;
assign bus = (en) ? data : 'bz;

endmodule: BusDriver

// Memory module
// Same module from lecture 14, combinational read, sequential write
// To read, read enable, bus
// To write, posedge, write enable, bus
module Memory
#(parameter AW = 8, DW = 8)
(input logic re, we, clock,
 input logic [AW-1:0] addr,
 inout tri [DW-1:0] data);

logic [DW-1:0] rData;
logic [DW-1:0] M[2**AW];

assign data = (re) ? rData : 'bz;

always_ff @(posedge clock)
    if(we)
        M[addr] <= data;

assign rData = M[addr];

endmodule: Memory

module range_check
    #(parameter WIDTH = 24)
    (input logic [WIDTH-1:0] low, high, val,
     output logic is_between);

    assign is_between = ((low <= val) & (val <= high)); 

endmodule: range_check

module offset_check
    #(parameter WIDTH = 24)
    (input logic [WIDTH-1:0] low, delta, val,
     output logic is_between);

    logic [WIDTH-1:0] offset;

    assign offset = low + delta;

    range_check #(WIDTH) m1(.low, 
                            .high(offset), 
                            .val, 
                            .is_between);

endmodule: offset_check