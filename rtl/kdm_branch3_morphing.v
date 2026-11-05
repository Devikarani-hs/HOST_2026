`timescale 1ns / 1ps

module kdm_rolling_key #(
    parameter BUFFER_DEPTH  = 4096,
    parameter ADDR_WIDTH    = 12,
    parameter KEY_WIDTH     = 256,
    parameter DIGEST_ROUNDS = 4
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire [7:0]             s_axis_tdata,
    input  wire                   s_axis_tvalid,
    input  wire                   s_axis_tlast,
    output wire                   s_axis_tready,
    input  wire                   force_rekey,
    output reg  [KEY_WIDTH-1:0]   derived_key,
    output reg                    key_valid,
    output wire [ADDR_WIDTH-1:0]  byte_count,
    output reg                    sca_trigger,
    output reg                    fi_alarm
);

    localparam ST_IDLE    = 2'b00;
    localparam ST_STREAM  = 2'b01;
    localparam ST_PERMUTE = 2'b10;
    localparam ST_UPDATE  = 2'b11;

    // DMR Control Registers
    (* DONT_TOUCH = "yes" *) reg [1:0] current_state, next_state;
    (* DONT_TOUCH = "yes" *) reg [1:0] current_state_shadow, next_state_shadow;
    (* DONT_TOUCH = "yes" *) reg [2:0] round_counter;
    (* DONT_TOUCH = "yes" *) reg [2:0] round_counter_shadow;
    reg       round_done;

    // Free-running Temporal Morphing Scheduler LFSR (Controls dummy stalls & register rotation)
    (* DONT_TOUCH = "yes" *) reg [31:0] morph_lfsr = 32'hACE1BEEF;
    always @(posedge clk) begin
        morph_lfsr <= {morph_lfsr[30:0], morph_lfsr[31] ^ morph_lfsr[21] ^ morph_lfsr[1] ^ morph_lfsr[0]};
    end

    (* DONT_TOUCH = "yes" *) reg [1:0] stall_budget;
    wire inject_dummy_cycle = (morph_lfsr[2:0] != 3'b000) && (stall_budget < 2'd2);

    // 4096-Byte Past-Data History BRAM
    (* ram_style = "block" *) reg [7:0] history_ram [0:BUFFER_DEPTH-1];
    (* DONT_TOUCH = "yes" *) reg [ADDR_WIDTH-1:0] wr_ptr;
    (* DONT_TOUCH = "yes" *) reg [ADDR_WIDTH-1:0] wr_ptr_shadow;
    wire [ADDR_WIDTH-1:0] rd_ptr = wr_ptr ^ 12'h5A5;
    reg  [7:0]            history_rdata;

    integer k;
    initial begin
        for (k = 0; k < BUFFER_DEPTH; k = k + 1) history_ram[k] = 8'h5A;
        history_rdata = 8'h5A;
    end

    // STRICT BRAM INFERENCE (No Asynchronous Reset)
    always @(posedge clk) begin
        if (!fi_alarm) begin
            if (s_axis_tvalid && s_axis_tready)
                history_ram[wr_ptr] <= s_axis_tdata;
            history_rdata <= history_ram[rd_ptr];
        end
    end

    (* DONT_TOUCH = "yes" *) reg [31:0] sponge_state [0:7];
    reg [31:0] next_state_sponge [0:7];

    (* DONT_TOUCH = "yes" *) wire [255:0] sponge_state_morph_vec = {
        sponge_state[7], sponge_state[6], sponge_state[5], sponge_state[4],
        sponge_state[3], sponge_state[2], sponge_state[1], sponge_state[0]
    };

    `define ROTL32(val, shift) (((val) << (shift)) | ((val) >> (32 - (shift))))
    wire [31:0] raw_input_word = {16'h5A82, history_rdata, s_axis_tdata} ^ {20'h0, wr_ptr};

    integer i, j;
    always @(*) begin
        for (i = 0; i < 8; i = i + 1) next_state_sponge[i] = sponge_state[i];
        next_state_sponge[0] = `ROTL32(sponge_state[0] + sponge_state[1] + 32'h9E3779B9, 7);
        next_state_sponge[1] = `ROTL32(sponge_state[1] ^ next_state_sponge[0], 9);
        next_state_sponge[2] = `ROTL32(sponge_state[2] + sponge_state[3] + 32'hBB67AE85, 13);
        next_state_sponge[3] = `ROTL32(sponge_state[3] ^ next_state_sponge[2], 18);
        next_state_sponge[4] = `ROTL32(sponge_state[4] + sponge_state[5] + 32'h3C6EF372, 11);
        next_state_sponge[5] = `ROTL32(sponge_state[5] ^ next_state_sponge[4], 14);
        next_state_sponge[6] = `ROTL32(sponge_state[6] + sponge_state[7] + 32'hA54FF53A, 17);
        next_state_sponge[7] = `ROTL32(sponge_state[7] ^ next_state_sponge[6], 23);
    end

    wire stream_handshake = s_axis_tvalid && s_axis_tready;
    wire boundary_reached = (wr_ptr == (BUFFER_DEPTH - 1)) && stream_handshake;
    wire rekey_condition  = boundary_reached || (stream_handshake && s_axis_tlast) || force_rekey;

    assign s_axis_tready  = (current_state == ST_STREAM || current_state == ST_IDLE) && !fi_alarm;
    assign byte_count     = wr_ptr;

    always @(*) begin
        next_state = current_state;
        case (current_state)
            ST_IDLE:    next_state = ST_STREAM;
            ST_STREAM:  if (rekey_condition) next_state = ST_PERMUTE;
            ST_PERMUTE: if (round_done) next_state = ST_UPDATE;
            ST_UPDATE:  next_state = ST_STREAM;
            default:    next_state = ST_IDLE;
        endcase

        next_state_shadow = current_state_shadow;
        case (current_state_shadow)
            ST_IDLE:    next_state_shadow = ST_STREAM;
            ST_STREAM:  if (rekey_condition) next_state_shadow = ST_PERMUTE;
            ST_PERMUTE: if (round_done) next_state_shadow = ST_UPDATE;
            ST_UPDATE:  next_state_shadow = ST_STREAM;
            default:    next_state_shadow = ST_IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state        <= ST_IDLE;
            current_state_shadow <= ST_IDLE;
            wr_ptr               <= 0;
            wr_ptr_shadow        <= 0;
            round_counter        <= 0;
            round_counter_shadow <= 0;
            stall_budget         <= 0;
            round_done           <= 1'b0;
            key_valid            <= 1'b0;
            sca_trigger          <= 1'b0;
            fi_alarm             <= 1'b0;
            derived_key          <= 256'h0;
            for (j = 0; j < 8; j = j + 1) sponge_state[j] <= 32'h6A09E667 + j;
        end else begin
            if ((current_state != current_state_shadow) || 
                (wr_ptr != wr_ptr_shadow) || 
                (round_counter != round_counter_shadow)) begin
                fi_alarm  <= 1'b1;
                key_valid <= 1'b0;
            end else if (!fi_alarm) begin
                current_state        <= next_state;
                current_state_shadow <= next_state_shadow;
                key_valid            <= 1'b0;
                sca_trigger          <= 1'b0;

                case (current_state)
                    ST_IDLE: begin
                        round_counter        <= 0;
                        round_counter_shadow <= 0;
                        stall_budget         <= 0;
                        round_done           <= 1'b0;
                    end
                    ST_STREAM: begin
                        if (stream_handshake) begin
                            wr_ptr        <= (wr_ptr == BUFFER_DEPTH - 1) ? 0 : wr_ptr + 1'b1;
                            wr_ptr_shadow <= (wr_ptr_shadow == BUFFER_DEPTH - 1) ? 0 : wr_ptr_shadow + 1'b1;
                            sponge_state[wr_ptr[2:0]] <= sponge_state[wr_ptr[2:0]] ^ raw_input_word;
                        end
                        if (rekey_condition) begin
                            sca_trigger          <= 1'b1;
                            round_counter        <= 0;
                            round_counter_shadow <= 0;
                            stall_budget         <= 0;
                            round_done           <= 1'b0;
                        end
                    end
                    ST_PERMUTE: begin
                        sca_trigger <= 1'b1;
                        if (inject_dummy_cycle) begin
                            // Temporal Morphing Stall: Rotate register file dynamically & inject dummy toggle
                            stall_budget <= stall_budget + 1'b1;
                            for (j = 0; j < 8; j = j + 1) begin
                                sponge_state[j] <= sponge_state[(j + 1) % 8] ^ morph_lfsr;
                            end
                        end else begin
                            // Execute genuine permutation round at desynchronized clock index
                            for (j = 0; j < 8; j = j + 1) begin
                                sponge_state[j] <= next_state_sponge[j];
                            end
                            if (round_counter == DIGEST_ROUNDS - 1) begin
                                round_done <= 1'b1;
                            end else begin
                                round_counter        <= round_counter + 1'b1;
                                round_counter_shadow <= round_counter_shadow + 1'b1;
                            end
                        end
                    end
                    ST_UPDATE: begin
                        derived_key          <= sponge_state_morph_vec;
                        key_valid            <= 1'b1;
                        sca_trigger          <= 1'b0;
                        round_counter        <= 0;
                        round_counter_shadow <= 0;
                        stall_budget         <= 0;
                        round_done           <= 1'b0;
                    end
                endcase
            end
        end
    end
endmodule
