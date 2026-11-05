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
