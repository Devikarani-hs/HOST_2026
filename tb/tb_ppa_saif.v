`timescale 1ns / 1ps
module tb_ppa_saif;
    reg clk, rst_n, s_axis_tvalid, s_axis_tlast, force_rekey;
    reg [7:0] s_axis_tdata;
    wire s_axis_tready, key_valid, sca_trigger, fi_alarm;
    wire [255:0] derived_key;
    wire [11:0] byte_count;

    kdm_rolling_key dut (
        .clk(clk), .rst_n(rst_n), .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid), .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready), .force_rekey(force_rekey),
        .derived_key(derived_key), .key_valid(key_valid),
        .byte_count(byte_count), .sca_trigger(sca_trigger), .fi_alarm(fi_alarm)
    );

    initial begin clk = 0; forever #10 clk = ~clk; end // 50 MHz

    integer i, j;
    reg [31:0] prng = 32'hDEADBEEF;

    initial begin
        rst_n = 0; s_axis_tvalid = 0; s_axis_tlast = 0; s_axis_tdata = 0; force_rekey = 0;
        #120; rst_n = 1; #40;

        for (i = 0; i < 50; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                @(posedge clk);
                prng = {prng[30:0], prng[31] ^ prng[21] ^ prng[1] ^ prng[0]};
                s_axis_tvalid <= 1'b1;
                s_axis_tdata  <= prng[7:0];
                s_axis_tlast  <= (j == 3) ? 1'b1 : 1'b0;
            end
            @(posedge clk);
            s_axis_tvalid <= 1'b0; s_axis_tlast <= 1'b0;
            wait (key_valid == 1'b1);
            repeat(5) @(posedge clk);
        end
        #100; 
        $stop; // CRITICAL: Allows TCL to execute close_saif
    end
endmodule
