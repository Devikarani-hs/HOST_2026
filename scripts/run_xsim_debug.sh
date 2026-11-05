#!/bin/bash
echo "Compiling RTL and Testbench..."
xvlog -sv src/prng_lfsr32.v "./tb/tb_tvla.v"

echo "Elaborating design..."
xelab -debug typical -top "tb_tvla" -snapshot tb_tvla_snap

echo "Running Simulation and dumping VCD..."
xsim tb_tvla_snap -tclbatch <(echo "log_wave -recursive *; run 50 us; quit")

echo "Simulation complete. Check dump_masked.vcd"
