#!/bin/bash
set -e

echo "[INFO] 1. Copying SDF for Timing Delays..."
cp -f synth_out/kdm_timesim.sdf .

echo "[INFO] 2. Compiling Post-Route Netlist and 100-Trace TVLA Testbench..."
rm -rf xsim.dir/kdm_postroute_snap
xvlog -work work synth_out/kdm_timesim.v tb/tb_kdm_rolling_key.v
xelab --debug typical --maxdelay -L simprims_ver -L secureip -s kdm_postroute_snap work.tb_kdm_rolling_key work.glbl

echo "[INFO] 3. Running Gate-Level Simulation (Dumping VCD)..."
xsim kdm_postroute_snap -tclbatch scripts/xsim_vcd.tcl

echo "[INFO] 4. Cleaning up SDF..."
rm -f kdm_timesim.sdf

echo "[INFO] 5. Executing Python VCD-to-Trace Conversion..."
python3 scripts/parse_vcd.py
