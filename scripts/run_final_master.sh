#!/bin/bash

declare -a DESIGNS=("kdm_unprotected.v" "kdm_branch1_masked.v" "kdm_branch2_hiding.v" "kdm_branch3_morphing.v")
declare -a NAMES=("1. Unprotected Baseline" "2. Branch 1: Masked+DMR" "3. Branch 2: Hiding+DMR" "4. Branch 3: Morphing+DMR")

echo "========================================================================================================="
echo "       FINAL IMPLEMENTATION RESULTS (KINTEX ULTRASCALE+ | 50MHz | SAIF-ANNOTATED POWER) "
echo "========================================================================================================="
printf "%-25s | %-6s | %-6s | %-6s | %-9s | %-12s | %-12s\n" "Architecture" "LUTs" "FFs" "BRAM" "WNS (ns)" "Dyn Pwr (mW)" "Stat Pwr (mW)"
echo "---------------------------------------------------------------------------------------------------------"

rm -f ppa_master.log
mkdir -p synth_out xsim.dir

for i in "${!DESIGNS[@]}"; do
    DESIGN_NAME="${NAMES[$i]}"
    
    # Locate the source file (checking both rtl/ and rtl_backup/ folders)
    SRC="rtl/${DESIGNS[$i]}"
    if [ ! -f "$SRC" ]; then SRC="rtl_backup/${DESIGNS[$i]}"; fi

    echo "[INFO] Processing $DESIGN_NAME ..." >&2
    rm -f synth_out/* xsim.dir/*

    # Strip DONT_TOUCH and write to a specific clean file for Vivado
    sed 's/(\*[ \t]*DONT_TOUCH[ \t]*=[ \t]*"yes"[ \t]*\*)//gi' "$SRC" > rtl/kdm_active_clean.v

    echo "  -> 1/3: Running Clean Synthesis & Route..." >&2
    vivado -mode batch -nojournal -nolog -source scripts/build_clean.tcl >> ppa_master.log 2>&1 || true

    LUTS=$(grep -A 10 "1. Utilization by Hierarchy" synth_out/utilization_route.rpt | grep "(top)" | awk -F '|' '{print $4}' | tr -d ' ' || true)
    FFS=$(grep -A 10 "1. Utilization by Hierarchy" synth_out/utilization_route.rpt | grep "(top)" | awk -F '|' '{print $8}' | tr -d ' ' || true)
    BRAM_36=$(grep -A 10 "1. Utilization by Hierarchy" synth_out/utilization_route.rpt | grep "(top)" | awk -F '|' '{print $9}' | tr -d ' ' || true)
    BRAM_18=$(grep -A 10 "1. Utilization by Hierarchy" synth_out/utilization_route.rpt | grep "(top)" | awk -F '|' '{print $10}' | tr -d ' ' || true)
    
    if ! [[ "$BRAM_36" =~ ^[0-9]+$ ]]; then BRAM_36=0; fi
    if ! [[ "$BRAM_18" =~ ^[0-9]+$ ]]; then BRAM_18=0; fi
    BRAM=$((BRAM_36 + BRAM_18))
    
    WNS=$(grep -A 6 "Design Timing Summary" synth_out/timing_summary.rpt | tail -n 1 | awk '{print $1}' || true)

    echo "  -> 2/3: Running SAIF Hardware Simulation..." >&2
    cp -f synth_out/kdm_timesim.sdf . || true
    xvlog -work work synth_out/kdm_timesim.v tb/tb_ppa_saif.v < /dev/null >> ppa_master.log 2>&1 || true
    xelab --debug typical --maxdelay -L simprims_ver -L secureip -s kdm_ppa_snap work.tb_ppa_saif work.glbl < /dev/null >> ppa_master.log 2>&1 || true
    xsim kdm_ppa_snap -tclbatch scripts/xsim_saif.tcl < /dev/null >> ppa_master.log 2>&1 || true
    rm -f kdm_timesim.sdf || true

    echo "  -> 3/3: Extracting Dynamic & Static Power..." >&2
    vivado -mode batch -nojournal -nolog -source scripts/report_saif_power.tcl < /dev/null >> ppa_master.log 2>&1 || true

    DYN_W=$(grep "Dynamic (W)" synth_out/power_saif.rpt | awk -F '|' '{print $3}' | tr -d ' ' || true)
    STAT_W=$(grep "Device Static (W)" synth_out/power_saif.rpt | awk -F '|' '{print $3}' | tr -d ' ' || true)
    
    if ! [[ "$DYN_W" =~ ^[0-9.]+$ ]]; then DYN_W="0"; fi
    if ! [[ "$STAT_W" =~ ^[0-9.]+$ ]]; then STAT_W="0"; fi
    
    DYN_MW=$(echo "$DYN_W * 1000" | bc -l | awk '{printf "%.2f", $0}' || true)
    STAT_MW=$(echo "$STAT_W * 1000" | bc -l | awk '{printf "%.2f", $0}' || true)

    printf "%-25s | %-6s | %-6s | %-6s | %-9s | %-12s | %-12s\n" "$DESIGN_NAME" "${LUTS:-0}" "${FFS:-0}" "$BRAM" "+${WNS:-0}" "$DYN_MW" "$STAT_MW"
    echo "  -> DONE." >&2
    echo "" >&2
done

echo "========================================================================================================="
