`timescale 1ns/1ps
module control_unit(input wire [31:0] instruction,
    output reg reg_write, output reg mem_write, output reg mem_read,
    output reg alu_src_imm, output reg [3:0] alu_control,
    output reg [1:0] writeback_select, output reg branch,
    output reg jump, output reg jalr, output reg use_pc_as_alu_a,
    output reg [2:0] branch_funct3);
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire [6:0] funct7 = instruction[31:25];
    localparam ALU_ADD=4'd0, ALU_SUB=4'd1, ALU_AND=4'd2, ALU_OR=4'd3,
               ALU_XOR=4'd4, ALU_SLL=4'd5, ALU_SRL=4'd6, ALU_SRA=4'd7,
               ALU_SLT=4'd8, ALU_SLTU=4'd9, ALU_PASS_B=4'd10;
    // writeback_select: 00=ALU, 01=memory, 10=PC+4, 11=immediate (LUI)
    always @(*) begin
        reg_write=0; mem_write=0; mem_read=0; alu_src_imm=0;
        alu_control=ALU_ADD; writeback_select=2'b00; branch=0; jump=0;
        jalr=0; use_pc_as_alu_a=0; branch_funct3=funct3;
        case (opcode)
            7'b0110011: begin // R-type
                reg_write=1;
                case (funct3)
                    3'b000: alu_control = (funct7[5] ? ALU_SUB : ALU_ADD);
                    3'b001: alu_control=ALU_SLL;
                    3'b010: alu_control=ALU_SLT;
                    3'b011: alu_control=ALU_SLTU;
                    3'b100: alu_control=ALU_XOR;
                    3'b101: alu_control=(funct7[5] ? ALU_SRA : ALU_SRL);
                    3'b110: alu_control=ALU_OR;
                    3'b111: alu_control=ALU_AND;
                endcase
            end
            7'b0010011: begin // I-type ALU
                reg_write=1; alu_src_imm=1;
                case (funct3)
                    3'b000: alu_control=ALU_ADD;
                    3'b010: alu_control=ALU_SLT;
                    3'b011: alu_control=ALU_SLTU;
                    3'b100: alu_control=ALU_XOR;
                    3'b110: alu_control=ALU_OR;
                    3'b111: alu_control=ALU_AND;
                    3'b001: alu_control=ALU_SLL;
                    3'b101: alu_control=(funct7[5] ? ALU_SRA : ALU_SRL);
                endcase
            end
            7'b0000011: begin // loads
                reg_write=1; mem_read=1; alu_src_imm=1; writeback_select=2'b01; alu_control=ALU_ADD;
            end
            7'b0100011: begin // stores
                mem_write=1; alu_src_imm=1; alu_control=ALU_ADD;
            end
            7'b1100011: begin // branches
                branch=1; alu_control=ALU_SUB;
            end
            7'b1101111: begin // JAL
                reg_write=1; jump=1; writeback_select=2'b10;
            end
            7'b1100111: begin // JALR
                reg_write=1; jump=1; jalr=1; alu_src_imm=1; writeback_select=2'b10;
            end
            7'b0110111: begin // LUI
                reg_write=1; writeback_select=2'b11; alu_control=ALU_PASS_B; alu_src_imm=1;
            end
            7'b0010111: begin // AUIPC
                reg_write=1; use_pc_as_alu_a=1; alu_src_imm=1; alu_control=ALU_ADD;
            end
            7'b0001111: begin // FENCE: no-op in this simple single-hart implementation
            end
            7'b1110011: begin // ECALL/EBREAK are treated as no-op; CSR instructions unsupported
            end
            default: begin end // illegal/unsupported instruction behaves as no-op
        endcase
    end
endmodule
