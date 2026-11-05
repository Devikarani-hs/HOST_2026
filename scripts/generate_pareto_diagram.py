import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Ensure output directory exists
os.makedirs("synth_out", exist_ok=True)

# Set global matplotlib styles for publication quality
plt.rcParams['font.sans-serif'] = 'DejaVu Sans'
plt.rcParams['axes.edgecolor'] = '#333333'
plt.rcParams['axes.linewidth'] = 1.0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 8.5), dpi=300, gridspec_kw={'width_ratios': [1.15, 1]})
fig.patch.set_facecolor('white')

# ==============================================================================
# PANEL A: ARCHITECTURAL BLOCK DIAGRAM OF THE PARETO STUDY WORKFLOW
# ==============================================================================
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 10)
ax1.axis('off')
ax1.set_title("A. Comparative Countermeasure Evaluation Workflow", fontsize=13, fontweight='bold', pad=12, color='#1a1a1a')

def draw_box(ax, x, y, w, h, title, subtitle, bg_color, border_color, title_color='#000000'):
    box = patches.FancyBboxPatch(
        (x, y), w, h,
        boxstyle="round,pad=0.08,rounding_size=0.15",
        facecolor=bg_color, edgecolor=border_color, linewidth=1.8
    )
    ax.add_patch(box)
    ax.text(x + w/2, y + h*0.68, title, ha='center', va='center', fontsize=9.5, fontweight='bold', color=title_color)
    ax.text(x + w/2, y + h*0.30, subtitle, ha='center', va='center', fontsize=8.0, color='#222222')

def draw_arrow(ax, x1, y1, x2, y2):
    ax.annotate(
        '', xy=(x2, y2), xytext=(x1, y1),
        arrowprops=dict(arrowstyle="->,head_width=0.25,head_length=0.25", color='#444444', lw=1.5)
    )

# Stage 1: Baseline Architecture
draw_box(
    ax1, 2.0, 8.5, 6.0, 1.1,
    "STAGE 1: DMR-Hardened KDM Baseline (Active FI Immune)",
    "360 LUTs | 552 FFs | Delay: 2.684 ns | Passive Leakage: |t| = 219.23, CNN = 100%",
    "#e8f4f8", "#2b5c8f", "#10375c"
)

# Stage 2: Three Countermeasure Branches
draw_box(
    ax1, 0.2, 5.8, 2.9, 1.6,
    "Branch 1: Boolean Masking",
    "• 2-Share Sponge State (x ⊕ m)\n• PRNG Mask Refreshing\n• Targets: Data Independence",
    "#fff3e6", "#d97724", "#8c4600"
)
draw_box(
    ax1, 3.55, 5.8, 2.9, 1.6,
    "Branch 2: Amplitude Hiding",
    "• Dual-Rail Precharge / RO Noise\n• Balanced Toggle Activity\n• Targets: Constant Power SNR",
    "#fef0f0", "#c93b3b", "#7a1616"
)
draw_box(
    ax1, 6.9, 5.8, 2.9, 1.6,
    "Branch 3: Temporal Morphing",
    "• Dynamic Register Shuffling\n• Random Dummy Cycle Stalls\n• Targets: Trace Desynchronization",
    "#f3e8ff", "#7e3af2", "#4a154b"
)

# Arrows from Stage 1 to Stage 2
draw_arrow(ax1, 3.5, 8.42, 1.65, 7.48)
draw_arrow(ax1, 5.0, 8.42, 5.0, 7.48)
draw_arrow(ax1, 6.5, 8.42, 8.35, 7.48)

# Stage 3: Dual-Track Evaluation Engine
draw_box(
    ax1, 0.4, 3.1, 4.3, 1.6,
    "STAGE 3A: Hardware Overhead Track (Vivado)",
    "• Post-Route Utilization (LUTs, FFs, BRAM)\n• Static Timing Analysis (WNS & Critical Path)\n• SAIF Back-Annotated Dynamic Power (mW)",
    "#eef7ee", "#2e7d32", "#1b5e20"
)
draw_box(
    ax1, 5.3, 3.1, 4.3, 1.6,
    "STAGE 3B: Security Assessment Track (XSim + ML)",
    "• Post-Route SDF Timing VCD Extraction (100 ps)\n• Non-Specific Welch's t-test (TVLA |t| ≤ 4.5)\n• 1D-CNN Key Recovery Profiling Attack",
    "#eef7ee", "#2e7d32", "#1b5e20"
)

# Arrows from Stage 2 to Stage 3
for bx in [1.65, 5.0, 8.35]:
    draw_arrow(ax1, bx, 5.72, 2.55, 4.78)
    draw_arrow(ax1, bx, 5.72, 7.45, 4.78)

# Stage 4: Pareto Front Optimization Filter
draw_box(
    ax1, 1.5, 0.4, 7.0, 1.6,
    "STAGE 4: Multi-Objective Pareto Frontier Selection",
    "Minimize: Area (LUT/FF) + Delay (ns) + Power (mW)   |   Subject to: |t| < 4.5 & F_max ≥ 350 MHz\nOutput: Optimal Wire-Speed 100Gbps Side-Channel & Fault Resilient KDM Architecture",
    "#e6f2ff", "#0052cc", "#002966"
)

# Arrows from Stage 3 to Stage 4
draw_arrow(ax1, 2.55, 3.02, 4.0, 2.08)
draw_arrow(ax1, 7.45, 3.02, 6.0, 2.08)

# ==============================================================================
# PANEL B: EXPECTED PARETO FRONTIER (SECURITY vs. HARDWARE OVERHEAD)
# ==============================================================================
ax2.set_title("B. Expected Design Space & Pareto Frontier", fontsize=13, fontweight='bold', pad=12, color='#1a1a1a')
ax2.set_yscale('log')
ax2.set_xlim(0, 260)
ax2.set_ylim(0.8, 500)

# Shaded Feasibility Zones
ax2.axhspan(0.8, 4.5, color='#d4edda', alpha=0.45, label='SCA Secure Zone (|t| < 4.5)')
ax2.axvspan(175, 260, color='#f8d7da', alpha=0.35, label='Timing/Area Violation Zone (>175% Overhead)')

# Threshold Lines
ax2.axhline(4.5, color='#d9534f', linestyle='--', linewidth=1.8, label='TVLA Leakage Threshold (|t| = 4.5)')
ax2.axvline(175, color='#333333', linestyle=':', linewidth=1.5, label='100Gbps Wire-Speed Cutoff')

# Data Points: (Hardware Overhead %, Expected Max |t|-stat, Label, Color, Marker)
design_points = [
    (0.0,   219.23, "Unprotected Baseline\n(329 LUTs, |t|=219.2)", "#555555", "X"),
    (9.4,   215.00, "DMR Only (Phase 6.1)\n(+9.4% LUTs, FI Safe)", "#2b5c8f", "^"),
    (38.0,    9.80, "Temporal Morphing\n(Low Area, FIFO Jitter)", "#7e3af2", "s"),
    (165.0,  14.20, "Amplitude Hiding (WDDL/Noise)\n(FPGA Routing Imbalance)", "#c93b3b", "D"),
    (215.0,   2.10, "Full TI Boolean Masking\n(Secure, High LUT/Delay)", "#d97724", "o"),
    (82.0,    2.65, "Pareto Optimal: 1st-Order Masked\nSponge + DMR (+82% LUTs, |t|=2.65)", "#1b5e20", "*")
]

for x, y, label, color, marker in design_points:
    size = 180 if marker == "*" else 110
    ax2.scatter(x, y, color=color, marker=marker, s=size, zorder=5, edgecolors='black', linewidth=0.8)
    
    # Custom text offsets to avoid overlap
    dx, dy = 6, 0
    if "Unprotected" in label:
        dx, dy = 8, 30
    elif "DMR Only" in label:
        dx, dy = 8, -45
    elif "Temporal" in label:
        dx, dy = 8, 1.5
    elif "Amplitude" in label:
        dx, dy = -65, 5.0
    elif "Full TI" in label:
        dx, dy = -68, -0.8
    elif "Pareto Optimal" in label:
        dx, dy = 8, -0.6

    ax2.annotate(
        label, xy=(x, y), xytext=(x + dx, y + dy),
        fontsize=8.2, fontweight='bold' if marker == "*" else 'normal',
        color=color,
        bbox=dict(boxstyle="round,pad=0.2", fc="white", ec=color, alpha=0.85, lw=1.0),
        arrowprops=dict(arrowstyle="->", connectionstyle="arc3,rad=0.1", color=color, lw=1.0)
    )

# Plot Pareto Frontier Curve connecting non-dominated solutions
pareto_x = [9.4, 38.0, 82.0, 215.0]
pareto_y = [215.0, 9.80, 2.65, 2.10]
ax2.plot(pareto_x, pareto_y, color='#1b5e20', linestyle='-.', linewidth=1.8, alpha=0.8, label='Pareto Frontier Curve')

ax2.set_xlabel("Composite Hardware Overhead (% LUT Increase over 329-LUT Baseline)", fontsize=10.5, fontweight='bold')
ax2.set_ylabel("Maximum TVLA Leakage Statistic max(|t|) [Log Scale]", fontsize=10.5, fontweight='bold')
ax2.grid(True, which="both", linestyle="--", alpha=0.4)
ax2.legend(loc='upper right', fontsize=8.5, framealpha=0.95)

plt.tight_layout()
png_path = "synth_out/pareto_optimization_study.png"
pdf_path = "synth_out/pareto_optimization_study.pdf"
plt.savefig(png_path, dpi=300)
plt.savefig(pdf_path)

print("================================================================================")
print(" PARETO OPTIMIZATION STUDY DIAGRAM GENERATED SUCCESSFULLY")
print("================================================================================")
print(f" -> Visual Diagram (PNG): {png_path}")
print(f" -> Publication Vector (PDF): {pdf_path}\n")
print(" EXPECTED COMPARATIVE BENCHMARK MATRIX (TARGET PROJECTIONS):")
print("--------------------------------------------------------------------------------")
print(f"{'Architecture Variant':<28} | {'LUTs (Est.)':<12} | {'Crit. Path':<12} | {'Expected |t|':<12} | {'Status'}")
print("--------------------------------------------------------------------------------")
print(f"{'1. Unprotected Baseline':<28} | {'329 (1.00x)':<12} | {'1.692 ns':<12} | {'219.23 (FAIL)':<12} | {'Vulnerable'}")
print(f"{'2. DMR Hardened (Current)':<28} | {'360 (1.09x)':<12} | {'2.684 ns':<12} | {'~215.0 (FAIL)':<12} | {'FI Safe Only'}")
print(f"{'3. Branch A: Boolean Masked':<28} | {'~600 (1.82x)':<12} | {'~2.950 ns':<12} | {'< 4.50 (PASS)':<12} | {'Pareto Optimal'}")
print(f"{'4. Branch B: Amp. Hiding':<28} | {'~870 (2.64x)':<12} | {'~3.800 ns':<12} | {'~14.20 (FAIL)':<12} | {'Routing Skew'}")
print(f"{'5. Branch C: Temp. Morphing':<28} | {'~455 (1.38x)':<12} | {'~2.810 ns':<12} | {'~9.80  (WARN)':<12} | {'Latency Jitter'}")
print("================================================================================")
