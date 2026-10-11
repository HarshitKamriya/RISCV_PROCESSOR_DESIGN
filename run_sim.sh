#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
mkdir -p build
iverilog -g2012 -Wall -o build/tb.vvp rtl/*.v tb/tb_rv32i_cpu.v
vvp build/tb.vvp
