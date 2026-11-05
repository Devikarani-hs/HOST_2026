#!/bin/bash
set -e
PROJ_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd "${PROJ_ROOT}"

echo "[INFO] 0. Preparing SDF Timing Data..."
# Copy the SDF file to the execution directory so xelab can resolve the internal path
cp synth_out/kdm_timesim.sdf .

echo "[INFO] 1. Compiling Post-Route Netlist with Xilinx Primitives..."
xvlog -d GATE_LEVEL synth_out/kdm_timesim.v tb/tb_kdm_rolling_key.v $XILINX_VIVADO/data/verilog/src/glbl.v

echo "[INFO] 2. Elaborating Gate-Level Simulation with Timing (SDF)..."
xelab -debug typical -maxdelay -L simprims_ver -L secureip -top tb_kdm_rolling_key -top glbl -snapshot kdm_postroute_snap

echo "[INFO] 3. Running Simulation to Dump Switching Activity (SAIF)..."
xsim kdm_postroute_snap -tclbatch scripts/xsim_saif.tcl

echo "[INFO] 4. Running Vivado Power Analyzer..."
vivado -mode batch -source scripts/report_annotated_power.tcl -nolog -nojournal

# Clean up the copied SDF file to keep the directory clean
rm kdm_timesim.sdf

echo ""
echo "==================================================================="
echo " ANNOTATED DYNAMIC POWER SUMMARY (Kintex UltraScale+)"
echo "==================================================================="
grep -A 20 "1. Summary" synth_out/power_annotated.rpt
