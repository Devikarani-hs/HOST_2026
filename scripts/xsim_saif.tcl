open_saif synth_out/kdm_sim.saif
catch { log_saif [get_objects -r /tb_ppa_saif/dut/*] }
run -all
close_saif
exit
