import os
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches

os.makedirs("synth_out", exist_ok=True)
plt.rcParams['font.sans-serif'] = 'DejaVu Sans'

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(16, 13), dpi=300)
fig.patch.set_facecolor('white')

def draw_block(ax, x, y, w, h, title, body, bg, ec, tc='#000000', lw=1.8):
    box = patches.FancyBboxPatch(
        (x, y), w, h, boxstyle="round,pad=0.06,rounding_size=0.12",
        facecolor=bg, edgecolor=ec, linewidth=lw
    )
    ax.add_patch(box)
    ax.text(x + w/2, y + h*0.70, title, ha='center', va='center', fontsize=9.5, fontweight='bold', color=tc)
    ax.text(x + w/2, y + h*0.30, body, ha='center', va='center', fontsize=8.0, color='#222222')

def draw_arrow(ax, x1, y1, x2, y2, label="", color='#333333'):
    ax.annotate(
        '', xy=(x2, y2), xytext=(x1, y1),
        arrowprops=dict(arrowstyle="->,head_width=0.22,head_length=0.22", color=color, lw=1.6)
    )
    if label:
        ax.text((x1+x2)/2, (y1+y2)/2 + 0.18, label, ha='center', va='center', fontsize=7.5, fontweight='bold', color=color)

# ==============================================================================
# PANEL A: EXISTING SYSTEM (PANTHERUN STEALTH AES BASELINE ARCHITECTURE)
# ==============================================================================
ax1.set_xlim(0, 16)
ax1.set_ylim(0, 6.5)
ax1.axis('off')
ax1.set_title("A. Existing System Architecture: Unprotected Real-Time Rolling-Key KDM (Protocol-Level Security Only)",
              fontsize=12.5, fontweight='bold', color='#7a1616', pad=10)

# Outer KDM dashed enclosure
kdm_box1 = patches.FancyBboxPatch((3.6, 0.4), 8.4, 4.3, boxstyle="round,pad=0.1",
                                  facecolor='#fafafa', edgecolor='#888888', linestyle='--', linewidth=1.5)
ax1.add_patch(kdm_box1)
ax1.text(7.8, 4.5, "Existing Unprotected FPGA Key Derivation Module (KDM) — Vulnerable to Physical SCA & Glitching",
         ha='center', va='center', fontsize=9, fontweight='bold', color='#555555')

draw_block(ax1, 0.3, 2.8, 2.6, 1.5, "Incoming Network Packet",
           "AXI4-Stream (100Gbps)\ns_axis_tdata [7:0]\ns_axis_tvalid / tlast", "#e8f4f8", "#2b5c8f", "#10375c")

draw_block(ax1, 4.0, 5.1, 7.6, 1.0, "Format-Preserving Header Bypass (Unencrypted Header Path)",
           "No Change in Data Format | Identical Data Volume | No Handshake or PKI Overhead", "#eef7ee", "#2e7d32", "#1b5e20")

draw_block(ax1, 4.0, 2.6, 3.5, 1.5, "4096-Byte Past-Data BRAM",
           "history_ram [4096 x 8-bit]\nStores Plaintext Past Payload\nUnmasked Read/Write", "#fff3e6", "#d97724", "#8c4600")

draw_block(ax1, 4.0, 0.7, 3.5, 1.4, "Unguarded Control FSM",
           "wr_ptr [11:0] | round_counter\nTriggers every Packet (tlast)\nor 4096 Bytes (Vulnerable to FI)", "#fef0f0", "#c93b3b", "#7a1616")

draw_block(ax1, 8.1, 1.6, 3.6, 2.5, "Single-Share Sponge Core",
           "sponge_state [0:7] (256-bit)\n4-Round ARX Permutation\n\n[!] High CMOS Toggle Leakage\n(10k-Trace TVLA |t| >> 4.5)", "#fef0f0", "#c93b3b", "#7a1616")

draw_block(ax1, 12.7, 2.8, 3.0, 1.5, "Stealth AES-256 Core",
           "Encrypts Payload Only\nRolling Key [255:0]\n100Gbps Wire-Speed Out", "#e8f4f8", "#2b5c8f", "#10375c")

draw_arrow(ax1, 1.6, 4.3, 4.0, 5.6, "Packet Header")
draw_arrow(ax1, 11.6, 5.6, 14.2, 4.3, "Header")
draw_arrow(ax1, 2.9, 3.55, 4.0, 3.55, "Payload")
draw_arrow(ax1, 2.9, 3.2, 4.0, 1.4, "tlast/valid")
draw_arrow(ax1, 7.5, 3.35, 8.1, 3.35, "Unmasked")
draw_arrow(ax1, 7.5, 1.4, 8.1, 2.2, "FSM Ctrl")
draw_arrow(ax1, 11.7, 2.85, 12.7, 3.3, "derived_key[255:0]", "#c93b3b")

# ==============================================================================
# PANEL B: PROPOSED SYSTEM (DMR + 1st-ORDER BOOLEAN MASKED KDM ARCHITECTURE)
# ==============================================================================
ax2.set_xlim(0, 16)
ax2.set_ylim(0, 6.8)
ax2.axis('off')
ax2.set_title("B. Proposed Hardened System Architecture: 1st-Order Boolean Masked + DMR KDM (Physical SCA & FI Immune)",
              fontsize=12.5, fontweight='bold', color='#1b5e20', pad=10)

kdm_box2 = patches.FancyBboxPatch((3.4, 0.3), 8.8, 5.9, boxstyle="round,pad=0.1",
                                  facecolor='#f4fbf4', edgecolor='#2e7d32', linestyle='--', linewidth=1.8)
ax2.add_patch(kdm_box2)
ax2.text(7.8, 5.95, "Proposed Hardened FPGA KDM — 1st-Order Boolean Masking (|t| <= 4.5) + Dual Modular Redundancy (FI Safe)",
         ha='center', va='center', fontsize=9, fontweight='bold', color='#1b5e20')

draw_block(ax2, 0.3, 2.8, 2.6, 1.6, "Incoming AXI4-Stream",
           "100Gbps Payload Stream\ns_axis_tdata [7:0]\ns_axis_tvalid / tlast", "#e8f4f8", "#2b5c8f", "#10375c")

draw_block(ax2, 3.7, 4.2, 3.7, 1.4, "Masked 4096B Past-Data BRAM",
           "RAMB36E2: s_axis_tdata ^ M0\nReads Past Masked History\nhistory_rdata <= ram[rd_ptr]", "#eef7ee", "#2e7d32", "#1b5e20")

draw_block(ax2, 3.7, 2.4, 3.7, 1.4, "64-Bit Xorshift PRNG Engine",
           "Parallel Per-Cycle Mask Gen\nfresh_mask[0:7] (256-bit/cycle)\nSplits Input: S0 = X^M, S1 = M", "#fff3e6", "#d97724", "#8c4600")

draw_block(ax2, 3.7, 0.6, 3.7, 1.4, "DMR Shadow Control & Checker",
           "Primary vs. Shadow FSM / Ptr\nContinuous Glitch Comparison\nLocks System (fi_alarm = 1)", "#e6f2ff", "#0052cc", "#002966")

draw_block(ax2, 8.0, 3.6, 3.9, 1.9, "Domain 0: Masked Share 0",
           "sponge_state_share0 [0:7]\n4-Round ARX + Per-Cycle Remask\n(* DONT_TOUCH = \"yes\" *)", "#eef7ee", "#2e7d32", "#1b5e20")

draw_block(ax2, 8.0, 1.3, 3.9, 1.9, "Domain 1: Masked Share 1",
           "sponge_state_share1 [0:7]\nIndependent Mask Diffusion Path\nZero 1st-Order Data Correlation", "#eef7ee", "#2e7d32", "#1b5e20")

draw_block(ax2, 12.7, 2.6, 3.0, 1.9, "Hardened Stealth AES-256",
           "Share Recombination (S0 ^ S1)\nGated by !fi_alarm & key_valid\n100Gbps Wire-Speed Secure Out", "#e8f4f8", "#2b5c8f", "#10375c")

draw_arrow(ax2, 2.9, 3.9, 3.7, 4.8, "Payload")
draw_arrow(ax2, 2.9, 3.4, 3.7, 3.1, "Absorb")
draw_arrow(ax2, 2.9, 2.9, 3.7, 1.3, "Control")
draw_arrow(ax2, 5.55, 3.8, 5.55, 4.2, "Mask M0", "#d97724")
draw_arrow(ax2, 7.4, 4.8, 8.0, 4.8, "Share 0 (X^M)")
draw_arrow(ax2, 7.4, 3.3, 8.0, 4.2, "Remask")
draw_arrow(ax2, 7.4, 2.8, 8.0, 2.3, "Share 1 (M)")
draw_arrow(ax2, 7.4, 1.3, 8.0, 1.6, "DMR Valid", "#0052cc")
draw_arrow(ax2, 11.9, 4.5, 12.7, 3.8, "S0 [255:0]", "#1b5e20")
draw_arrow(ax2, 11.9, 2.2, 12.7, 3.2, "S1 [255:0]", "#1b5e20")

plt.tight_layout()
plt.savefig("existing_vs_proposed_block_diagram.png", dpi=300)
plt.savefig("synth_out/existing_vs_proposed_block_diagram.png", dpi=300)
plt.savefig("synth_out/existing_vs_proposed_block_diagram.pdf")
print("[SUCCESS] Generated synth_out/existing_vs_proposed_block_diagram.png and .pdf")
