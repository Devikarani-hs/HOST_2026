set_part xcku5p-ffvb676-2-e
read_verilog rtl/kdm_active_clean.v
synth_design -top kdm_rolling_key -part xcku5p-ffvb676-2-e
opt_design
place_design
route_design
write_checkpoint -force synth_out/kdm_routed.dcp
write_verilog -force -mode timesim -sdf_anno true synth_out/kdm_timesim.v
write_sdf -force synth_out/kdm_timesim.sdf
report_utilization -file synth_out/utilization_route.rpt
report_timing_summary -file synth_out/timing_summary.rpt
exit
