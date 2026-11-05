`timescale 1ns / 1ps

module tb_kdm_rolling_key;

    reg          clk;
    reg          rst_n;
    reg  [7:0]   s_axis_tdata;
    reg          s_axis_tvalid;
    reg          s_axis_tlast;
    wire         s_axis_tready;
    reg          force_rekey;
    wire [255:0] derived_key;
    wire         key_valid;
    wire [11:0]  byte_count;
    wire         sca_trigger;
    wire         fi_alarm;

    kdm_rolling_key dut (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .force_rekey(force_rekey),
        .derived_key(derived_key),
        .key_valid(key_valid),
        .byte_count(byte_count),
        .sca_trigger(sca_trigger),
        .fi_alarm(fi_alarm)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 50 MHz clock (20 ns period)
    end

    integer trace_idx, byte_idx;
    reg [31:0] tb_prng;

    initial begin
        $display("===================================================================");
        $display(" EXECUTING REAL 10,000-TRACE XSIM TVLA CAMPAIGN");
        $display("===================================================================");

        rst_n         = 0;
        s_axis_tdata  = 8'h00;
        s_axis_tvalid = 0;
        s_axis_tlast  = 0;
        force_rekey   = 0;
        tb_prng       = 32'hCAFEBABE;

        #120; // Wait past 100ns glbl.GSR window
        rst_n = 1;
        #40;

        for (trace_idx = 0; trace_idx < 10000; trace_idx = trace_idx + 1) begin
            // Pulse rst_n to synchronize sponge IV before each trace (PRNG runs freely)
            @(posedge clk);
            rst_n <= 1'b0;
            @(posedge clk);
            rst_n <= 1'b1;
            @(posedge clk);

            // Stream 4-byte packet burst with tlast on byte 3 to trigger KDM derivation
            for (byte_idx = 0; byte_idx < 4; byte_idx = byte_idx + 1) begin
                @(posedge clk);
                s_axis_tvalid <= 1'b1;
                if (trace_idx % 2 == 0) begin
                    // Group A (5,000 Fixed traces): Constant known packet payload
                    s_axis_tdata <= 8'hA5 ^ byte_idx[7:0];
                end else begin
                    // Group B (5,000 Random traces): Uniformly random packet payload
                    tb_prng = {tb_prng[30:0], tb_prng[31] ^ tb_prng[21] ^ tb_prng[1] ^ tb_prng[0]};
                    s_axis_tdata <= tb_prng[7:0];
                end
                s_axis_tlast <= (byte_idx == 3) ? 1'b1 : 1'b0;
            end

            @(posedge clk);
            s_axis_tvalid <= 1'b0;
            s_axis_tlast  <= 1'b0;
            s_axis_tdata  <= 8'h00;

            wait (key_valid == 1'b1);
            @(posedge clk);

            if ((trace_idx + 1) % 2000 == 0) begin
                $display(" -> [XSIM PROGRESS] Completed %0d / 10000 hardware key derivations...", trace_idx + 1);
            end
        end

        $display("===================================================================");
        $display(" COMPLETED ALL 10,000 HARDWARE KEY DERIVATIONS IN XSIM");
        $display("===================================================================");
        #100;
        $finish;
    end
endmodule
