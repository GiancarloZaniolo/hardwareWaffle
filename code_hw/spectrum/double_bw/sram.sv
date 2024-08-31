module sram
    #(parameter                         NUM_WORDS=131072,
      parameter                         WORD_WIDTH=32,
      parameter logic [WORD_WIDTH-1:0]  RESET_VAL='b0)
    (input  logic                           clk, rst_l, we,
     input  logic [$clog2(NUM_WORDS)-1:0]   read_addr_1, read_addr_2, write_addr,
     input  logic [WORD_WIDTH-1:0]          write_data,
     output logic [WORD_WIDTH-1:0]          read_data_1, read_data_2);

    // The memory for the SRAM
    logic [WORD_WIDTH-1:0]  memory[NUM_WORDS-1:0];

    // Handle initialization and writing to the memory
    always_ff @(posedge clk, negedge rst_l) begin
        if (!rst_l) begin
            memory <= '{default: RESET_VAL};
        end else if (we) begin
            memory[write_addr] <= write_data;
        end
    end

    // Handle reading from memory
    assign read_data_1 = memory[read_addr_1];
    assign read_data_2 = memory[read_addr_2];


endmodule: sram