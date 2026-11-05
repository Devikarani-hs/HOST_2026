#!/bin/bash
declare -a NAMES=("1. Unprotected Baseline" "2. Branch 1: Masked+DMR" "3. Branch 2: Hiding+DMR" "4. Branch 3: Morphing+DMR")

NUM_TRACES=10000

echo "========================================================================================================="
echo "  STARTING BRAM-OPTIMIZED TVLA EVALUATION ($NUM_TRACES TRACES)"
echo "========================================================================================================="

mkdir -p traces
rm -rf traces/*.txt xsim.dir/*

for i in {0..3}; do
    DESIGN_ID=$((i+1))
    DESIGN_NAME="${NAMES[$i]}"
    
    echo "---------------------------------------------------------------------------------------------------------"
    echo "[INFO] Executing Gate-Level TVLA Simulation for $DESIGN_NAME ..."
    
    # Run Verilog Trace Generation
    xvlog -work work tb/tb_tvla.v < /dev/null > /dev/null 2>&1
    xelab -L simprims_ver -L secureip -s kdm_tvla_snap work.tb_tvla < /dev/null > /dev/null 2>&1
    xsim kdm_tvla_snap -R -testplusarg TRACE_COUNT=$NUM_TRACES -testplusarg DESIGN_ID=$DESIGN_ID < /dev/null > /dev/null 2>&1
    
    # Run Python Statistical Analysis
    python3 scripts/calculate_tvla.py traces/fixed_traces.txt traces/random_traces.txt "$DESIGN_NAME"
done

echo "========================================================================================================="
echo "  TVLA EVALUATION COMPLETE."
echo "========================================================================================================="
