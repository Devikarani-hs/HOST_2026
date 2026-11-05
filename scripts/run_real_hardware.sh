#!/bin/bash
echo "[INFO] Compiling Real Hardware RTL..."
# Replace tb_kdm_rolling_key.v with your actual hardware testbench file if different
xvlog -sv src/prng_lfsr32.v rtl/*.v tb/tb_kdm_rolling_key.v

echo "[INFO] Elaborating and Simulating..."
xelab -debug typical -top tb_kdm_rolling_key -snapshot tb_hw_snap
xsim tb_hw_snap -tclbatch <(echo "log_wave -recursive *; run 50 us; quit")

echo "[SUCCESS] dump_masked.vcd generated."
