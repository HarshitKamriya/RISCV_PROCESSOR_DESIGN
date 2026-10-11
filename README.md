# RV32I Single-Cycle CPU (Verilog-2001)

A modular 32-bit single-cycle RISC-V core intended for Icarus Verilog and GTKWave.

## Implemented instruction subset

- R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- I-type ALU: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
- Upper immediate: LUI, AUIPC
- Loads: LB, LH, LW, LBU, LHU
- Stores: SB, SH, SW
- Branches: BEQ, BNE, BLT, BGE, BLTU, BGEU
- Jumps: JAL, JALR
- FENCE is treated as a no-op in this simple single-hart design.

## Important scope note

This is a teaching core for the main integer datapath. It does not implement machine-mode CSRs, traps/interrupts, ECALL/EBREAK semantics, FENCE.I, or the Zicsr/Zifencei extensions. Unsupported instructions behave like no-ops. It also does not raise exceptions for misaligned accesses or illegal instructions. Do not describe this as a fully privileged/spec-compliant implementation of every RV32I execution-environment feature.

## Files

- `rtl/rv32i_cpu.v`: top-level CPU wiring
- `rtl/pc_register.v`: clocked PC register with synchronous reset
- `rtl/instruction_memory.v`: instruction ROM, initialized from a hex file
- `rtl/register_file.v`: 32 x 32-bit registers, x0 hardwired to zero
- `rtl/immediate_generator.v`: I/S/B/U/J immediates
- `rtl/control_unit.v`: instruction decoding and control signals
- `rtl/alu.v`: arithmetic, logic, shift, and comparison operations
- `rtl/branch_unit.v`: signed/unsigned branch decisions
- `rtl/data_memory.v`: byte-addressed little-endian memory and load/store widths
- `programs/program.hex`: smoke-test program
- `tb/tb_rv32i_cpu.v`: self-checking testbench

## Run with Icarus Verilog

Run from this directory so the relative path `programs/program.hex` resolves correctly:

```sh
mkdir -p build
iverilog -g2012 -Wall -o build/tb.vvp rtl/*.v tb/tb_rv32i_cpu.v
vvp build/tb.vvp
```

Expected final message:

```text
PASS: RV32I smoke test passed (ADDI, ADD, SW, LW, BEQ, PC control).
```

The testbench writes `build/rv32i_cpu.vcd`. Open it with:

```sh
gtkwave build/rv32i_cpu.vcd
```

## Program tested

1. `addi x1, x0, 5`
2. `addi x2, x0, 7`
3. `add x3, x1, x2`  -> x3 = 12
4. `sw x3, 0(x0)`    -> memory[0..3] = 12 in little-endian format
5. `lw x4, 0(x0)`    -> x4 = 12
6. `beq x3, x4, +8`  -> skips the next instruction
7. `addi x5, x0, 99` -> skipped
8. `addi x5, x0, 42` -> x5 = 42
9. `jal x0, 0`       -> self-loop

## Extending the design

For a more complete implementation, add illegal-instruction detection, access-fault/alignment handling, CSR registers and trap state, machine-mode control flow (`MRET`), and the desired Zicsr/Zifencei extensions. For FPGA synthesis, replace the asynchronous-read memories with a memory style supported by the target FPGA if block RAM inference is required.
