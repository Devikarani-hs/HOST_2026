# -------------------------------------------------------------------------
# Physical Constraints for IEEE HOST Double-Blind Submission
# Target Device: AMD/Xilinx Kintex UltraScale+ (xcku5p-ffvb676-2-e)
# -------------------------------------------------------------------------
set_property PART xcku5p-ffvb676-2-e [current_project]
create_clock -period 8.000 -name clk -waveform {0.000 4.000} [get_ports clk]
set_false_path -from [get_ports rst_n]
