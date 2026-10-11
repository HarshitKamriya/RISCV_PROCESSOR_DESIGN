`timescale 1ns/1ps
module instruction_memory #(
    parameter INIT_FILE = "program.hex",
    parameter WORDS = 256
)(input wire [31:0] address, output wire [31:0] instruction);
    reg [31:0] mem [0:WORDS-1];
    integer i;
    initial begin
        for (i = 0; i < WORDS; i = i + 1) mem[i] = 32'h00000013; // NOP: ADDI x0,x0,0
        if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
    end
    assign instruction = mem[address[31:2]];
endmodule
