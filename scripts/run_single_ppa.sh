#!/bin/bash
set -e # We WANT it to crash loudly if there is an error so we can see it

echo "==================================================================="
echo " 1. PREPARING RTL: UNPROTECTED BASELINE (Stripping DONT_TOUCH)"
echo "==================================================================="
# Delete old reports so we don't accidentally read leftover files
rm -rf synth_out/power_saif.rpt synth_out/utilization_route.rpt synth_out/kdm_sim.saif

# Overwrite the top module with the baseline, stripping DONT_TOUCH
sed 's/(\*[ \t]*DONT_TOUCH[ \t]*=[ \t]*"yes"[ \t]*\*)//gi' rtl/kdm_unprotected.v > rtl/kdm_rolling_key.v

echo "==================================================================="
echo " 2. RUNNING VIVADO SYNTHESIS & PnR (VISIBLE OUTPUT)"
echo "==================================================================="
./scripts/run_pnr.sh

echo "==================================================================="
echo " 3. RUNNING XSIM SDF SIMULATION TO GENERATE SAIF"
echo "==================================================================="
cp -f synth_out/kdm_timesim.sdf .
rm -rf xsim.dir/kdm_ppa_snap
xvlog -work work synth_out/kdm_timesim.v tb/tb_ppa_saif.v
xelab --debug typical --maxdelay -L simprims_ver -L secureip -s kdm_ppa_snap work.tb_ppa_saif work.glbl

cat << 'TCL_EOF' > scripts/xsim_saif.tcl
open_saif synth_out/kdm_sim.saif
log_saif [get_objects -r /tb_ppa_saif/dut/*]
run -all
close_saif
exit
TCL_EOF

xsim kdm_ppa_snap -tclbatch scripts/xsim_saif.tcl
rm -f kdm_timesim.sdf

echo "==================================================================="
echo " 4. VIVADO POWER ANALYSIS (SAIF BACK-ANNOTATION)"
echo "==================================================================="
cat << 'TCL_EOF' > scripts/report_saif_power.tcl
open_checkpoint synth_out/kdm_routed.dcp
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
