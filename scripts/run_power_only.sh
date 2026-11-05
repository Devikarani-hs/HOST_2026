#!/bin/bash
set -e

echo "==================================================================="
echo " 4. VIVADO POWER ANALYSIS (Auto-detecting DCP file)"
echo "==================================================================="
cat << 'TCL_EOF' > scripts/report_saif_power.tcl
# Automatically find the routed checkpoint
set dcp_files [glob -nocomplain synth_out/*route*.dcp]
if {[llength $dcp_files] == 0} {
    set dcp_files [glob -nocomplain synth_out/*.dcp]
}
set target_dcp [lindex $dcp_files 0]
puts "INFO: Auto-selected routed checkpoint: $target_dcp"

# Open the checkpoint and back-annotate the SAIF switching activity
open_checkpoint $target_dcp
read_saif -strip_path tb_ppa_saif/dut synth_out/kdm_sim.saif
report_power -file synth_out/power_saif.rpt
exit
TCL_EOF

vivado -mode batch -source scripts/report_saif_power.tcl

echo "==================================================================="
echo " 5. FINAL RESULTS FOR UNPROTECTED BASELINE"
echo "==================================================================="
grep -A 10 "1. Utilization by Hierarchy" synth_out/utilization_route.rpt | grep "(top)"
echo "-------------------------------------------------------------------"
grep -i "Total Dynamic Power" synth_out/power_saif.rpt
grep -i "Device Static Power" synth_out/power_saif.rpt
echo "==================================================================="
