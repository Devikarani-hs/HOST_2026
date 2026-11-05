#!/bin/bash

declare -a DESIGNS=("kdm_unprotected.v" "kdm_branch1_masked.v" "kdm_branch2_hiding.v")
declare -a NAMES=("1. Unprotected Baseline" "2. Branch 1: Masked+DMR" "3. Branch 2: Hiding+DMR")

# Secure RTL files
mkdir -p rtl_backup
mv rtl/*.v rtl_backup/ 2>/dev/null || true

for i in "${!DESIGNS[@]}"; do
    DESIGN_NAME="${NAMES[$i]}"
    TARGET_RTL="rtl_backup/${DESIGNS[$i]}"

    echo "========================================================================================================="
    echo "  BUILDING & VERIFYING: $DESIGN_NAME"
    echo "========================================================================================================="
    
    # Clean workspace
    rm -rf synth_out/* xsim.dir/* rtl/*.v
    
    # Isolate RTL
    sed 's/(\*[ \t]*DONT_TOUCH[ \t]*=[ \t]*"yes"[ \t]*\*)//gi' "$TARGET_RTL" > rtl/kdm_rolling_key.v
    
    # Run PnR (Silently)
    ./scripts/run_pnr.sh < /dev/null > /dev/null 2>&1
    
    # Run Power Analysis (Silently)
    cp -f synth_out/kdm_timesim.sdf . > /dev/null 2>&1 || true
    xvlog -work work synth_out/kdm_timesim.v tb/tb_ppa_saif.v < /dev/null > /dev/null 2>&1 || true
    xelab --debug typical --maxdelay -L simprims_ver -L secureip -s kdm_ppa_snap work.tb_ppa_saif work.glbl < /dev/null > /dev/null 2>&1 || true
    xsim kdm_ppa_snap -tclbatch scripts/xsim_saif.tcl < /dev/null > /dev/null 2>&1 || true
    rm -f kdm_timesim.sdf || true
    vivado -mode batch -nojournal -nolog -source scripts/report_saif_power.tcl < /dev/null > /dev/null 2>&1 || true

    # --- RAW VIVADO LOG VERIFICATION ---
    echo "--> RAW AREA (LUTs, FFs, BRAM):"
    grep -A 10 "1. Utilization by Hierarchy" synth_out/utilization_route.rpt | grep "(top)"
    echo ""
    echo "--> RAW POWER:"
    grep -E "Dynamic \(W\)|Device Static \(W\)" synth_out/power_saif.rpt
    echo ""
    echo "--> RAW TIMING (WNS):"
    grep -A 6 "Design Timing Summary" synth_out/timing_summary.rpt | tail -n 3
    echo ""
done

# Restore original files
mv -f rtl_backup/* rtl/ 2>/dev/null || true
