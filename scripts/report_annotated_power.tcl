set output_dir "synth_out"
open_checkpoint $output_dir/post_route.dcp

# Apply the simulated switching activity to the routed netlist
read_saif $output_dir/kdm_activity.saif -strip_path tb_kdm_rolling_key/dut

# Generate the annotated power report
report_power -file $output_dir/power_annotated.rpt
puts "\[INFO\] SAIF/VCD Annotated Power Report Generated Successfully."
exit
