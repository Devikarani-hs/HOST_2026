`timescale 1ns / 1ps

module tb_fi_kdm_rolling_key;

    parameter BUFFER_DEPTH = 4096;
    parameter ADDR_WIDTH   = 12;
    parameter KEY_WIDTH    = 256;
    parameter CLK_PERIOD   = 10;

    reg                   clk;
    reg                   rst_n;
    reg [7:0]             s_axis_tdata;
    reg                   s_axis_tvalid;
    reg                   s_axis_tlast;
    wire                  s_axis_tready;
    reg                   force_rekey;
    wire [KEY_WIDTH-1:0]  derived_key;
    wire                  key_valid;
    wire [ADDR_WIDTH-1:0] byte_count;
    wire                  sca_trigger;
    wire                  fi_alarm;

    kdm_rolling_key 
`ifndef GATE_LEVEL
    #(
        .BUFFER_DEPTH(BUFFER_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .KEY_WIDTH(KEY_WIDTH),
        .DIGEST_ROUNDS(4)
    ) 
`endif
    dut (
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

    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    task send_burst;
        input integer length;
        integer i;
        begin
            for (i = 0; i < length; i = i + 1) begin
                @(posedge clk);
                s_axis_tdata  = (i[7:0] ^ 8'hAA);
                s_axis_tvalid = 1'b1;
                s_axis_tlast  = (i == length - 1) ? 1'b1 : 1'b0;
                
                // Verilog-2001 timeout logic
                begin : tx_wait
                    fork
                        begin wait (s_axis_tready === 1'b1); disable tx_wait; end
                        begin #(CLK_PERIOD * 10); disable tx_wait; end
                    join
                end
            end
            @(posedge clk);
            s_axis_tvalid = 1'b0;
            s_axis_tlast  = 1'b0;
        end
    endtask

    task reset_dut;
        begin
            rst_n = 1'b0;
            #(CLK_PERIOD * 5);
            rst_n = 1'b1;
            #(CLK_PERIOD * 2);
        end
    endtask

    initial begin
        rst_n         = 1'b0;
        s_axis_tdata  = 8'h00;
        s_axis_tvalid = 1'b0;
        s_axis_tlast  = 1'b0;
        force_rekey   = 1'b0;

        $display("===================================================================");
        $display(" PHASE 6: FAULT INJECTION ON DMR-HARDENED ARCHITECTURE");
        $display("===================================================================");

        reset_dut();

        // -------------------------------------------------------------------------
        // CAMPAIGN 1: Pointer Corruption
        // -------------------------------------------------------------------------
        $display("\n[FI CAMPAIGN 1] Executing Known State Fallback Attack...");
        fork
            send_burst(64);
            begin
                wait (dut.wr_ptr == 12'd32);
                @(posedge clk);
                $display("   -> [INJECT] Forcing dut.wr_ptr to 0 (Simulated Voltage Glitch)");
                force dut.wr_ptr = 12'd0;
                #(CLK_PERIOD * 1);
                release dut.wr_ptr;
            end
        join
        
        begin : wait_c1
            fork
                begin wait(key_valid); disable wait_c1; end
                begin wait(fi_alarm); disable wait_c1; end
                begin #(CLK_PERIOD * 500); disable wait_c1; end
            join
        end

        if (fi_alarm) $display("   -> [MITIGATED] DMR detected pointer mismatch! System securely locked down.");
        else if (key_valid) $display("   -> [FAILED] Weak Key Derived: 0x%064x", derived_key);
        else $display("   -> [TIMEOUT] System hung without asserting alarm.");
        
        reset_dut();

        // -------------------------------------------------------------------------
        // CAMPAIGN 2: Round Counter Glitch
        // -------------------------------------------------------------------------
        $display("\n[FI CAMPAIGN 2] Executing Round Reduction Attack (Clock Glitch)...");
        fork
            send_burst(64);
            begin
                wait (dut.current_state == 2'b10);
                @(posedge clk);
                $display("   -> [INJECT] Forcing dut.round_counter to Max (Simulated Clock Glitch)");
                force dut.round_counter = 3'd3; 
                #(CLK_PERIOD * 1);
                release dut.round_counter;
            end
        join

        begin : wait_c2
            fork
                begin wait(key_valid); disable wait_c2; end
                begin wait(fi_alarm); disable wait_c2; end
                begin #(CLK_PERIOD * 500); disable wait_c2; end
            join
        end

        if (fi_alarm) $display("   -> [MITIGATED] DMR detected round counter mismatch! System securely locked down.");
        else if (key_valid) $display("   -> [FAILED] Weak Key Derived: 0x%064x", derived_key);
        else $display("   -> [TIMEOUT] System hung without asserting alarm.");

        reset_dut();

        // -------------------------------------------------------------------------
        // CAMPAIGN 3: EMP State Flip
        // -------------------------------------------------------------------------
        $display("\n[FI CAMPAIGN 3] Executing State Freeze Attack...");
        fork
            send_burst(64);
            begin
                wait (dut.current_state == 2'b10);
                @(posedge clk);
                $display("   -> [INJECT] Forcing dut.current_state to IDLE (Simulated EMP)");
                force dut.current_state = 2'b00;
                #(CLK_PERIOD * 1);
                release dut.current_state;
            end
        join

        begin : wait_c3
            fork
                begin wait(key_valid); disable wait_c3; end
                begin wait(fi_alarm); disable wait_c3; end
                begin #(CLK_PERIOD * 500); disable wait_c3; end
            join
        end

        if (fi_alarm) $display("   -> [MITIGATED] DMR detected FSM state mismatch! System securely locked down.");
        else if (key_valid) $display("   -> [FAILED] Weak Key Derived: 0x%064x", derived_key);
        else $display("   -> [RESULT] Pipeline Stalled! (Deadlock)");

        $display("\n===================================================================");
        $display(" DMR HARDWARE VERIFICATION COMPLETE");
        $display("===================================================================\n");
        $finish;
    end
endmodule
