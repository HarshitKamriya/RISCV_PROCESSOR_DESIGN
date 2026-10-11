`timescale 1ns/1ps
module tb_rv32i_cpu;
    reg clk = 0;
    reg reset = 1;
    wire [31:0] debug_pc, debug_instruction;
    integer cycles;
    always #5 clk = ~clk;

    rv32i_cpu #(.IMEM_FILE("programs/program.hex")) dut(
        .clk(clk), .reset(reset), .debug_pc(debug_pc), .debug_instruction(debug_instruction));

    initial begin
        $dumpfile("build/rv32i_cpu.vcd");
        $dumpvars(0, tb_rv32i_cpu);
        repeat (2) @(posedge clk);
        #1 reset = 0;
        for (cycles = 0; cycles < 20; cycles = cycles + 1) @(posedge clk);
        #1;
        if (dut.regs.regs[1] !== 32'd5) begin $display("FAIL: x1 expected 5 got %0d", dut.regs.regs[1]); $fatal; end
        if (dut.regs.regs[2] !== 32'd7) begin $display("FAIL: x2 expected 7 got %0d", dut.regs.regs[2]); $fatal; end
        if (dut.regs.regs[3] !== 32'd12) begin $display("FAIL: x3 expected 12 got %0d", dut.regs.regs[3]); $fatal; end
        if (dut.regs.regs[4] !== 32'd12) begin $display("FAIL: x4 expected 12 got %0d", dut.regs.regs[4]); $fatal; end
        if (dut.regs.regs[5] !== 32'd42) begin $display("FAIL: x5 expected 42 got %0d", dut.regs.regs[5]); $fatal; end
        if (dut.dmem.mem[0] !== 8'd12 || dut.dmem.mem[1] !== 8'd0) begin $display("FAIL: memory[0] incorrect"); $fatal; end
        if (dut.regs.regs[0] !== 32'd0) begin $display("FAIL: x0 changed"); $fatal; end
        $display("PASS: RV32I smoke test passed (ADDI, ADD, SW, LW, BEQ, PC control).");
        $finish;
    end
endmodule
