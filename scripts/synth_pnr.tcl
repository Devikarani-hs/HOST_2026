set target_part "xcku5p-ffvb676-2-e"
set output_dir  "synth_out"

# 1. Read Design Sources
read_verilog rtl/kdm_rolling_key.v

# 2. Synthesize Design in Out-of-Context (OOC) Mode
synth_design -top kdm_rolling_key -part $target_part -flatten_hierarchy rebuilt -mode out_of_context
write_checkpoint -force $output_dir/post_synth.dcp
report_utilization -file $output_dir/utilization_synth.rpt

# 3. Apply Timing and Physical Constraints
create_clock -period 10.000 -name clk [get_ports clk]

create_pblock pblock_kdm
add_cells_to_pblock [get_pblocks pblock_kdm] [get_cells -hierarchical *]
resize_pblock [get_pblocks pblock_kdm] -add {SLICE_X10Y10:SLICE_X25Y40}

# 4. Logic Optimization and Placement
opt_design -directive Explore
place_design -directive Explore
write_checkpoint -force $output_dir/post_place.dcp

# 5. Routing and Physical Optimization
route_design -directive Explore
phys_opt_design -directive Explore
write_checkpoint -force $output_dir/post_route.dcp

# 6. Generate Verification & Implementation Reports
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -file $output_dir/timing_summary.rpt
report_utilization -hierarchical -file $output_dir/utilization_route.rpt
report_power -file $output_dir/power_estimates.rpt
report_drc -file $output_dir/drc_checks.rpt

# 7. Export Gate-Level Netlist with SDF
write_verilog -mode timesim -sdf_anno true -force $output_dir/kdm_timesim.v
write_sdf -force $output_dir/kdm_timesim.sdf

puts "\[INFO\] Non-Project Synthesis and PnR completed successfully for Kintex UltraScale+ (OOC)."
exit
