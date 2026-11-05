import sys
import os
import matplotlib.pyplot as plt
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
                if not line:
                    continue
                
                if line.startswith('#'):
                    if current_time != -1:
                        timestamps.append(current_time)
                        toggles.append(current_toggles)
                    current_time = int(line[1:])
                    current_toggles = 0
                elif line.startswith('$'):
                    continue
                else:
                    current_toggles += 1
                    
            if current_time != -1:
                timestamps.append(current_time)
                toggles.append(current_toggles)
                
    except FileNotFoundError:
        print(f"[ERROR] Could not find {vcd_path}")
        sys.exit(1)
        
    return np.array(timestamps), np.array(toggles)

def aggregate_by_clock_cycle(timestamps, toggles, clock_period_ps=10000):
    # Aggregates raw picosecond toggles into total toggles per clock cycle.
    # Assuming a 10ns (10000ps) clock period by default.
    if len(timestamps) == 0:
        return np.array([]), np.array([])
        
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
        print(f"[ERROR] Could not find VCD files.")
        sys.exit(1)

    time_base, hd_base = extract_hamming_distance(baseline_vcd)
    time_mask, hd_mask = extract_hamming_distance(masked_vcd)

    # Convert raw picosecond timestamps to Clock Cycles (Assuming 10ns clock = 10000ps)
    print("Aggregating toggles into clock cycles...")
    cycles_base, agg_base = aggregate_by_clock_cycle(time_base, hd_base, clock_period_ps=10000)
    cycles_mask, agg_mask = aggregate_by_clock_cycle(time_mask, hd_mask, clock_period_ps=10000)

    print("Generating separated Temporal Leakage Plot...")
    
    # Use two subplots stacked vertically so the data doesn't occlude itself
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 6), sharex=True)

    # Plot 1: Unprotected Baseline
    ax1.plot(cycles_base, agg_base, color='#d32f2f', linewidth=1.5, 
             label="Unprotected Baseline (High Structural Leakage)")
    ax1.set_ylabel('Hamming Distance\n(Toggles/Cycle)', fontweight='bold', fontsize=11)
    ax1.grid(True, linestyle=':', alpha=0.7)
    ax1.legend(loc='upper right', fontsize=10, edgecolor='black')
    
    # Calculate sensible Y-axis limits
    max_hd = max(np.max(agg_base) if len(agg_base)>0 else 1, 
                 np.max(agg_mask) if len(agg_mask)>0 else 1)
    ax1.set_ylim(0, max_hd * 1.1)

    # Plot 2: Masked+DMR
    ax2.plot(cycles_mask, agg_mask, color='#388e3c', linewidth=1.5, 
             label="Branch 1: Masked+DMR (Suppressed Leakage)")
    ax2.set_xlabel('Simulation Time (Clock Cycles)', fontweight='bold', fontsize=11)
    ax2.set_ylabel('Hamming Distance\n(Toggles/Cycle)', fontweight='bold', fontsize=11)
    ax2.grid(True, linestyle=':', alpha=0.7)
    ax2.legend(loc='upper right', fontsize=10, edgecolor='black')
    ax2.set_ylim(0, max_hd * 1.1)
    
    # Zoom in on the active window (plot the first 500 clock cycles)
    ax2.set_xlim(0, 500)

    plt.tight_layout()
    plt.savefig('graphs/real_vcd_temporal_trace.png', dpi=300, bbox_inches='tight')
    plt.savefig('graphs/real_vcd_temporal_trace.pdf', bbox_inches='tight')

    print("SUCCESS: Separated Temporal Trace saved to graphs/real_vcd_temporal_trace.png")

if __name__ == "__main__":
    main()
