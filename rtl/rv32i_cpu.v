`timescale 1ns/1ps
module rv32i_cpu #(
    parameter IMEM_FILE = "program.hex",
    parameter IMEM_WORDS = 256,
    parameter DMEM_BYTES = 4096
)(input wire clk, input wire reset,
  output wire [31:0] debug_pc, output wire [31:0] debug_instruction);
    wire [31:0] pc, next_pc, instruction, imm;
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];
    wire [31:0] reg_data1, reg_data2, alu_a, alu_b, alu_result, mem_read_data, writeback_data;
    wire reg_write, mem_write, mem_read, alu_src_imm, branch, jump, jalr, use_pc_as_alu_a;
    wire [3:0] alu_control;
    wire [1:0] writeback_select;
    wire [2:0] branch_funct3;
    wire take_branch;
    wire [31:0] pc_plus4 = pc + 32'd4;
    wire [31:0] branch_target = pc + imm;
    wire [31:0] jalr_target = (reg_data1 + imm) & 32'hfffffffe;

    pc_register pc_reg(.clk(clk), .reset(reset), .next_pc(next_pc), .pc(pc));
    instruction_memory #(.INIT_FILE(IMEM_FILE), .WORDS(IMEM_WORDS)) imem(.address(pc), .instruction(instruction));
    immediate_generator immgen(.instruction(instruction), .immediate(imm));
    control_unit control(.instruction(instruction), .reg_write(reg_write), .mem_write(mem_write),
        .mem_read(mem_read), .alu_src_imm(alu_src_imm), .alu_control(alu_control),
        .writeback_select(writeback_select), .branch(branch), .jump(jump), .jalr(jalr),
        .use_pc_as_alu_a(use_pc_as_alu_a), .branch_funct3(branch_funct3));
    register_file regs(.clk(clk), .reset(reset), .write_enable(reg_write), .rs1(rs1), .rs2(rs2),
        .rd(rd), .write_data(writeback_data), .read_data1(reg_data1), .read_data2(reg_data2));
    assign alu_a = use_pc_as_alu_a ? pc : reg_data1;
    assign alu_b = alu_src_imm ? imm : reg_data2;
    alu alu_unit(.a(alu_a), .b(alu_b), .control(alu_control), .result(alu_result), .zero());
    branch_unit branch_check(.funct3(branch_funct3), .a(reg_data1), .b(reg_data2), .take_branch(take_branch));
    data_memory #(.BYTES(DMEM_BYTES)) dmem(.clk(clk), .reset(reset), .read_enable(mem_read),
        .write_enable(mem_write), .funct3(instruction[14:12]), .address(alu_result),
        .write_data(reg_data2), .read_data(mem_read_data));
    assign writeback_data = (writeback_select == 2'b01) ? mem_read_data :
                            (writeback_select == 2'b10) ? pc_plus4 :
                            (writeback_select == 2'b11) ? imm : alu_result;
    assign next_pc = jalr ? jalr_target :
                     (jump || (branch && take_branch)) ? branch_target : pc_plus4;
    assign debug_pc = pc;
    assign debug_instruction = instruction;
endmodule
