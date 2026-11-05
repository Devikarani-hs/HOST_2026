import sys
import os
import matplotlib.pyplot as plt
from mpl_toolkits.axes_grid1.inset_locator import mark_inset
import numpy as np

def extract_hamming_distance(vcd_path):
    print(f"Parsing VCD: {vcd_path}...")
    timestamps = []
    toggles = []
    current_time = -1
    current_toggles = 0
    try:
        with open(vcd_path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line: continue
                if line.startswith('#'):
                    if current_time != -1:
                        timestamps.append(current_time)
                        toggles.append(current_toggles)
                    current_time = int(line[1:])
                    current_toggles = 0
                elif line.startswith('$'): continue
                else: current_toggles += 1
            if current_time != -1:
                timestamps.append(current_time)
                toggles.append(current_toggles)
    except FileNotFoundError:
        print(f"[ERROR] Could not find {vcd_path}")
        sys.exit(1)
    return np.array(timestamps), np.array(toggles)

def aggregate_by_clock_cycle(timestamps, toggles, clock_period_ps=10000):
    if len(timestamps) == 0: return np.array([]), np.array([])
    max_time = np.max(timestamps)
    num_cycles = int(np.ceil(max_time / clock_period_ps))
    cycles = np.arange(num_cycles)
    cycle_toggles = np.zeros(num_cycles)
    for t, tog in zip(timestamps, toggles):
        cycle_idx = int(t / clock_period_ps)
        if cycle_idx < num_cycles:
            cycle_toggles[cycle_idx] += tog
    return cycles, cycle_toggles

def main():
    baseline_vcd = "dump_unprotected.vcd"
    masked_vcd   = "dump_masked.vcd"
    
    if not os.path.exists(baseline_vcd) or not os.path.exists(masked_vcd):
        print(f"[ERROR] Could not find VCD files in current directory.")
        sys.exit(1)

    time_base, hd_base = extract_hamming_distance(baseline_vcd)
    time_mask, hd_mask = extract_hamming_distance(masked_vcd)

    print("Aggregating toggles into clock cycles...")
    cycles_base, agg_base = aggregate_by_clock_cycle(time_base, hd_base, clock_period_ps=10000)
    cycles_mask, agg_mask = aggregate_by_clock_cycle(time_mask, hd_mask, clock_period_ps=10000)

    print("Generating separated Temporal Leakage Plot with Zoom Insets...")
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

    # Plot 1: Unprotected Baseline
    ax1.plot(cycles_base, agg_base, color='#d32f2f', linewidth=1.5, label="Unprotected Baseline (High Structural Leakage)")
    ax1.set_ylabel('Hamming Distance\n(Toggles/Cycle)', fontweight='bold', fontsize=11)
    ax1.grid(True, linestyle=':', alpha=0.7)
    ax1.legend(loc='upper right', fontsize=10, edgecolor='black')
    
    # Inset for Baseline (Zoom window 200-230)
    axins1 = ax1.inset_axes([0.65, 0.4, 0.25, 0.45])
    axins1.plot(cycles_base, agg_base, color='#d32f2f', linewidth=1.5)
    axins1.set_xlim(200, 230)
    
    # Determine local maximums for the zoomed Y-axis
    local_max_base = np.max(agg_base[200:230]) if len(agg_base) > 230 else 8
    local_max_mask = np.max(agg_mask[200:230]) if len(agg_mask) > 230 else 16
    
    axins1.set_ylim(0, local_max_base + 2)
    axins1.set_title("Zoom: Cycles 200-230", fontsize=9, fontweight='bold')
    axins1.grid(True, linestyle=':', alpha=0.5)
    axins1.set_xticks([200, 215, 230])
    mark_inset(ax1, axins1, loc1=2, loc2=4, fc="none", ec="0.5")

    # Plot 2: Masked+DMR
    ax2.plot(cycles_mask, agg_mask, color='#388e3c', linewidth=1.5, label="Proposed Branch: Masked+DMR (Algorithmic Noise)")
    ax2.set_xlabel('Simulation Time (Clock Cycles)', fontweight='bold', fontsize=11)
    ax2.set_ylabel('Hamming Distance\n(Toggles/Cycle)', fontweight='bold', fontsize=11)
    ax2.grid(True, linestyle=':', alpha=0.7)
    ax2.legend(loc='upper right', fontsize=10, edgecolor='black')
    
    # Inset for Masked (Zoom window 200-230)
    axins2 = ax2.inset_axes([0.65, 0.4, 0.25, 0.45])
    axins2.plot(cycles_mask, agg_mask, color='#388e3c', linewidth=1.5)
    axins2.set_xlim(200, 230)
    axins2.set_ylim(0, local_max_mask + 2)
    axins2.set_title("Zoom: Cycles 200-230", fontsize=9, fontweight='bold')
    axins2.grid(True, linestyle=':', alpha=0.5)
    axins2.set_xticks([200, 215, 230])
    mark_inset(ax2, axins2, loc1=2, loc2=4, fc="none", ec="0.5")
    
    # Overall plot bounds
    ax2.set_xlim(0, 500)
    max_hd = max(np.max(agg_base) if len(agg_base)>0 else 1, 
                 np.max(agg_mask) if len(agg_mask)>0 else 1)
    ax1.set_ylim(0, max_hd * 1.1)
    ax2.set_ylim(0, max_hd * 1.1)

    plt.tight_layout()
    os.makedirs('graphs', exist_ok=True)
    plt.savefig('graphs/real_vcd_temporal_trace_zoom.png', dpi=300, bbox_inches='tight')
    plt.savefig('graphs/real_vcd_temporal_trace_zoom.pdf', bbox_inches='tight')

    print("SUCCESS: Separated Temporal Trace with Zoom saved to graphs/real_vcd_temporal_trace_zoom.png")

if __name__ == "__main__":
    main()
