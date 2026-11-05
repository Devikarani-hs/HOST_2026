set dcp_files [glob -nocomplain synth_out/*route*.dcp]
if {[llength $dcp_files] == 0} { set dcp_files [glob -nocomplain synth_out/*.dcp] }
open_checkpoint [lindex $dcp_files 0]
catch { read_saif -strip_path tb_ppa_saif/dut synth_out/kdm_sim.saif }
report_power -file synth_out/power_saif.rpt
exit
