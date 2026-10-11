`timescale 1ns/1ps
module data_memory #(parameter BYTES=4096)(input wire clk, input wire reset,
    input wire read_enable, input wire write_enable, input wire [2:0] funct3,
    input wire [31:0] address, input wire [31:0] write_data, output reg [31:0] read_data);
    reg [7:0] mem [0:BYTES-1];
    integer i;
    wire [11:0] addr = address[11:0];
    always @(*) begin
        case (funct3)
            3'b000: read_data = {{24{mem[addr][7]}}, mem[addr]}; // LB
            3'b001: read_data = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]}; // LH
            3'b010: read_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]}; // LW
            3'b100: read_data = {24'b0, mem[addr]}; // LBU
            3'b101: read_data = {16'b0, mem[addr+1], mem[addr]}; // LHU
            default: read_data = 32'b0;
        endcase
    end
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < BYTES; i = i + 1) mem[i] <= 8'b0;
        end else if (write_enable) begin
            case (funct3)
                3'b000: mem[addr] <= write_data[7:0];
                3'b001: begin mem[addr] <= write_data[7:0]; mem[addr+1] <= write_data[15:8]; end
                3'b010: begin
                    mem[addr] <= write_data[7:0]; mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16]; mem[addr+3] <= write_data[31:24];
                end
                default: begin end
            endcase
        end
    end
endmodule
