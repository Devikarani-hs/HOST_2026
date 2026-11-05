#!/bin/bash

# 1. Generate a robust Hardware PRNG (Galois LFSR)
# This prevents the hardware mask generator from getting stuck in a zero-state lockup.
cat << 'VERILOG' > src/prng_lfsr32.v
module prng_lfsr32 (
    input wire clk,
    input wire rst,
    input wire en,
    output reg [31:0] rand_out
);
    always @(posedge clk) begin
        if (rst) begin
            // FATAL FLAW FIX: Never seed an LFSR with 32'h0 or it locks permanently.
            rand_out <= 32'hACE1_0001; 
        end else if (en) begin
            // 32-bit Galois LFSR polynomial
            rand_out <= {rand_out[30:0], rand_out[31] ^ rand_out[21] ^ rand_out[1] ^ rand_out[0]};
        end
    end
endmodule
VERILOG

# 2. Generate the Testbench Patch for continuous mask injection
# Integrate this block into your main tb_masked.sv
cat << 'VERILOG' > sim/tb_mask_driver_patch.sv
reg [31:0] dynamic_mask;

// APPROACH A: Testbench-Driven Mask (Ideal for TVLA Fixed-vs-Random testing)
always @(posedge clk) begin
    if (rst) begin
        dynamic_mask <= 32'h0;
    end else if (s_axis_tvalid) begin
        // FIX: $urandom must be called inside the active clock edge loop.
        // If called inside an initial block, the mask remains static forever.
        dynamic_mask <= $urandom(); 
    end
end

// APPROACH B: Hardware-Driven Mask Instantiation
/*
wire [31:0] hw_mask;
prng_lfsr32 prng_inst (
    .clk(clk),
    .rst(rst),
    .en(s_axis_tvalid),
    .rand_out(hw_mask)
);
*/

// Connect the dynamic noise to your Device Under Test (DUT)
/*
masked_kdm_dut dut (
    .clk(clk),
    .rst(rst),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tdata(plaintext),
    .mask_in(dynamic_mask), // Continuous noise injected here
    ...
);
*/
VERILOG

# 3. Create the XSim execution script to dump the new VCD
cat << 'SCRIPT' > scripts/run_xsim_debug.sh
#!/bin/bash
echo "Compiling Fixed RTL and Testbench..."
xvlog -sv src/prng_lfsr32.v sim/tb_masked.sv 

echo "Elaborating design..."
xelab -debug typical -top tb_masked -snapshot tb_masked_snap

echo "Running Simulation and dumping VCD..."
xsim tb_masked_snap -tclbatch <(echo "log_wave -recursive *; run 50 us; quit")

echo "Simulation complete. Check dump_masked.vcd"
SCRIPT
chmod +x scripts/run_xsim_debug.sh

echo "Debug scripts and patched Verilog files successfully generated."
