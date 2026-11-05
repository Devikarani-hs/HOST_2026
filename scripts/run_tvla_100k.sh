#!/bin/bash

echo "[INFO] Running simulation for 100,000 traces (Masked+DMR Branch)..."
# Pass plusargs using --testplusarg correctly for xsim
xsim tb_tvla_snap --testplusarg TRACE_COUNT=100000 --testplusarg DESIGN_ID=2 -tclbatch <(echo "run all; quit")

echo "========================================="
echo "[INFO] Verifying 100k trace generation..."
wc -l traces/fixed_traces.txt
echo "========================================="

echo "[INFO] Generating updated 100k TVLA plot..."
python3 scripts/plot_tvla.py
