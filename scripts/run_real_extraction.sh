#!/bin/bash
declare -a DESIGNS=("kdm_unprotected.v" "kdm_branch1_masked.v" "kdm_branch2_hiding.v" "kdm_branch3_morphing.v")
declare -a NAMES=("1. Unprotected Baseline" "2. Branch 1: Masked+DMR" "3. Branch 2: Hiding+DMR" "4. Branch 3: Morphing+DMR")

NUM_TRACES=10000

echo "========================================================================================================="
echo "  STARTING REAL GATE-LEVEL TVLA EXTRACTION ($NUM_TRACES TRACES)"
echo "  Note: This will take roughly 10 to 15 minutes per architecture."
echo "========================================================================================================="

mkdir -p rtl_backup traces
mv rtl/*.v rtl_backup/ 2>/dev/null || true

for i in {0..3}; do
    DESIGN_NAME="${NAMES[$i]}"
    TARGET_RTL="rtl_backup/${DESIGNS[$i]}"
    
    echo "---------------------------------------------------------------------------------------------------------"
    echo "[INFO] Processing $DESIGN_NAME ..."
    
    # FIX: Using rm -rf to cleanly delete folders and suppress warnings
    rm -rf rtl/*.v traces/*.vcd xsim.dir synth_out/* kdm_timesim.sdf
    mkdir -p xsim.dir
    sed 's/(\*[ \t]*DONT_TOUCH[ \t]*=[ \t]*"yes"[ \t]*\*)//gi' "$TARGET_RTL" > rtl/kdm_rolling_key.v
    
    # 1. Synthesize to get real physical gates and routing
    ./scripts/run_pnr.sh < /dev/null > /dev/null 2>&1
    cp -f synth_out/kdm_timesim.sdf . > /dev/null 2>&1 || true
    
    # 2. Compile Netlist and Testbench
    xvlog -work work synth_out/kdm_timesim.v tb/tb_real_tvla.v < /dev/null > /dev/null 2>&1 || true
    
    # 3. Simulate FIXED Traces
    echo "[INFO] Generating physical VCD traces for Fixed Data..."
    xelab --maxdelay -L simprims_ver -L secureip -s snap_fixed work.tb_real_tvla work.glbl < /dev/null > /dev/null 2>&1 || true
    xsim snap_fixed -R -testplusarg TRACE_COUNT=$NUM_TRACES -testplusarg FIXED_MODE=1 < /dev/null > /dev/null 2>&1 || true
    
    # 4. Simulate RANDOM Traces
    echo "[INFO] Generating physical VCD traces for Random Data..."
    xelab --maxdelay -L simprims_ver -L secureip -s snap_random work.tb_real_tvla work.glbl < /dev/null > /dev/null 2>&1 || true
    xsim snap_random -R -testplusarg TRACE_COUNT=$NUM_TRACES -testplusarg FIXED_MODE=0 < /dev/null > /dev/null 2>&1 || true
    
    # 5. Extract Toggles and Calculate TVLA
    python3 scripts/parse_real_vcd.py "$DESIGN_NAME"
    
    # 6. Delete massive VCDs to prevent out-of-storage crashes
    rm -f traces/*.vcd kdm_timesim.sdf
done

mv -f rtl_backup/* rtl/ 2>/dev/null || true
echo "========================================================================================================="
echo "  REAL TVLA EXTRACTION COMPLETE."
echo "========================================================================================================="
