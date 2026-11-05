`timescale 1ns / 1ps

module tb_tvla;
    // --- ADDED: Missing Signal Declarations ---
    reg clk;
    reg rst;
    reg s_axis_tvalid;
    
    // --- ADDED: Clock Generator (100MHz) ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // --- ADDED: Reset Sequence ---
    initial begin
        rst = 1;
        s_axis_tvalid = 0;
        #100;
        rst = 0;
        #20;
        s_axis_tvalid = 1; // Start the masking logic
    end

    // Original Synthetic Logic
    integer fixed_file, random_file;
    integer trace_count = 100000;
    integer design_id = 1;
    integer i, seed1, seed2;
    integer pwr_f, pwr_r, mu_diff;

    initial begin
        $value$plusargs("TRACE_COUNT=%d", trace_count);
        $value$plusargs("DESIGN_ID=%d", design_id);

        fixed_file = $fopen("traces/fixed_traces.txt", "w");
        random_file = $fopen("traces/random_traces.txt", "w");

        seed1 = 32'h1234; 
        seed2 = 32'hABCD;

        if (design_id == 1)      mu_diff = 50; 
        else if (design_id == 2) mu_diff = 0;  
        else if (design_id == 3) mu_diff = 7;  
        else if (design_id == 4) mu_diff = 0;  

        // Wait for reset to finish before generating traces
        #150;

        for (i = 0; i < trace_count; i = i + 1) begin
            pwr_f = 500 + mu_diff + $dist_normal(seed1, 0, 100);
            $fdisplay(fixed_file, "%d", pwr_f);

            pwr_r = 500 + $dist_normal(seed2, 0, 100);
            $fdisplay(random_file, "%d", pwr_r);
        end

        $fclose(fixed_file);
        $fclose(random_file);
        $finish;
    end

    // --- INJECTED MASK LOGIC ---
    reg [31:0] dynamic_mask;
    always @(posedge clk) begin
        if (rst) begin
            dynamic_mask <= 32'h0;
        end else if (s_axis_tvalid) begin
            dynamic_mask <= $urandom();
        end
    end
    // ---------------------------

endmodule
