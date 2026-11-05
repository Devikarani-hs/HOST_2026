open_vcd synth_out/kdm_traces.vcd
log_vcd [get_objects -quiet /tb_kdm_rolling_key/dut/sca_trigger*]
log_vcd [get_objects -quiet /tb_kdm_rolling_key/dut/*sponge_state*]
run -all
close_vcd
exit
