#!/bin/bash

# 1. Compile ONLY the Masked Branch and Testbench
echo "[INFO] Compiling Masked+DMR Hardware RTL..."
# We changed rtl/*.v to the specific masked file to prevent module overwriting
xvlog -sv src/prng_lfsr32.v rtl/kdm_branch1_masked.v tb/tb_kdm_rolling_key.v

echo "[INFO] Elaborating and Simulating to generate dump_masked.vcd..."
xelab -debug typical -top tb_kdm_rolling_key -snapshot tb_hw_snap
xsim tb_hw_snap -tclbatch <(echo "log_wave -recursive *; run 50 us; quit")

# 2. Update the Plot Script to save with a new name
sed -i 's/real_vcd_temporal_trace_zoom_2/real_vcd_temporal_trace_SECURE/g' scripts/plot_temporal_zoom.py

# 3. Re-run the plot script
echo "[INFO] Generating corrected Temporal Trace Plot..."
python3 scripts/plot_temporal_zoom.py
