`timescale 1ns / 1ps
module tb_real_tvla;
    integer dummy;
    reg clk;
    reg rst_n;
    reg [7:0] s_axis_tdata;
    reg s_axis_tvalid;
    
    integer trace_count = 10000;
    integer fixed_mode = 1;
    integer i;
    
    // Instantiate actual Post-Synthesis Netlist
    kdm_rolling_key uut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid)
    );
    
    always #10 clk = ~clk; // 50 MHz
    
    initial begin
        dummy = $value$plusargs("TRACE_COUNT=%d", trace_count);
        dummy = $value$plusargs("FIXED_MODE=%d", fixed_mode);
        
        if (fixed_mode == 1) $dumpfile("traces/real_fixed.vcd");
        else                 $dumpfile("traces/real_random.vcd");
        
        $dumpvars(0, tb_real_tvla.uut); // Dump all internal fabric wires
        
        clk = 0; rst_n = 0; s_axis_tvalid = 0; s_axis_tdata = 8'h00;
        #100;
        rst_n = 1;
        #20;
        
        // Feed 10,000 traces
        for (i = 0; i < trace_count; i = i + 1) begin
            @(posedge clk);
            s_axis_tvalid = 1;
            if (fixed_mode == 1) s_axis_tdata = 8'hDA; // Fixed Input
            else                 s_axis_tdata = $urandom; // Random Input
        end
        
        @(posedge clk);
        s_axis_tvalid = 0;
        #50;
        $finish;
    end
endmodule
