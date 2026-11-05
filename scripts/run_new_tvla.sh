#!/bin/bash

declare -a DESIGNS=("kdm_unprotected.v" "kdm_branch1_masked.v" "kdm_branch2_hiding.v" "kdm_branch3_morphing.v")
declare -a NAMES=("1. Unprotected Baseline" "2. Branch 1: Masked+DMR" "3. Branch 2: Hiding+DMR" "4. Branch 3: Morphing+DMR")

NUM_TRACES=10000

echo "========================================================================================================="
echo "  STARTING BRAM-OPTIMIZED TVLA EVALUATION ($NUM_TRACES TRACES)"
echo "========================================================================================================="

# 1. DELETE OLD TRACES TO SAVE MEMORY
echo "[INFO] Cleaning old traces to free up SSD space..."
mkdir -p traces
rm -rf traces/*.npy traces/*.csv traces/*.vcd traces/*.saif xsim.dir/* synth_out/*
echo "[INFO] Old trace memory wiped."

# 2. ISOLATE RTL
mkdir -p rtl_backup
mv rtl/*.v rtl_backup/ 2>/dev/null || true

for i in "${!DESIGNS[@]}"; do
    DESIGN_NAME="${NAMES[$i]}"
    TARGET_RTL="rtl_backup/${DESIGNS[$i]}"

    echo "---------------------------------------------------------------------------------------------------------"
    echo "[INFO] Processing $DESIGN_NAME ..."
    
    # Isolate current design
    rm -f rtl/*.v
    sed 's/(\*[ \t]*DONT_TOUCH[ \t]*=[ \t]*"yes"[ \t]*\*)//gi' "$TARGET_RTL" > rtl/kdm_rolling_key.v
    
    # Generate BRAM-Optimized Netlist
    echo "[INFO] Running Synthesis and Routing..."
    ./scripts/run_pnr.sh < /dev/null > /dev/null 2>&1
    
    # Run Gate-Level TVLA Simulation
    echo "[INFO] Executing Gate-Level TVLA Simulation ($NUM_TRACES traces)..."
    cp -f synth_out/kdm_timesim.sdf . > /dev/null 2>&1 || true
    xvlog -work work synth_out/kdm_timesim.v tb/tb_tvla.v < /dev/null > /dev/null 2>&1
    
    # Pass NUM_TRACES as a plusarg to the testbench
    xelab --debug typical --maxdelay -L simprims_ver -L secureip -s kdm_tvla_snap work.tb_tvla work.glbl -R -testplusarg TRACE_COUNT=$NUM_TRACES < /dev/null > /dev/null 2>&1
    
    # Rename generated traces to associate them with the current architecture
    mv traces/fixed_traces.npy traces/fixed_${i}.npy 2>/dev/null || true
    mv traces/random_traces.npy traces/random_${i}.npy 2>/dev/null || true
    
    # Run Statistical TVLA Analysis
    echo "[INFO] Calculating |t|-statistics..."
    python3 scripts/calculate_tvla.py traces/fixed_${i}.npy traces/random_${i}.npy "$DESIGN_NAME"
    
    rm -f kdm_timesim.sdf || true
done

# Restore original files
mv -f rtl_backup/* rtl/ 2>/dev/null || true

echo "========================================================================================================="
echo "  TVLA EVALUATION COMPLETE."
echo "========================================================================================================="
