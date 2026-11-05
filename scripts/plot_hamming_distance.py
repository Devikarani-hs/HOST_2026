import matplotlib.pyplot as plt
import re
import os

# Note: This is a simplified toggle counter. It assumes a standard VCD format.
print("[INFO] Parsing VCD file for toggle rates...")
toggles_per_time = []
current_time = 0
toggle_count = 0

try:
    with open("dump_masked.vcd", "r") as f:
        for line in f:
            line = line.strip()
            if line.startswith('#'):
                # New timestamp
                toggles_per_time.append(toggle_count)
                toggle_count = 0
                current_time = int(line[1:])
            elif line.startswith('b') or line in ['0', '1', 'x', 'z']:
                # Signal toggle
                toggle_count += 1
                
    print("[SUCCESS] VCD parsed.")
except FileNotFoundError:
    print("[ERROR] dump_masked.vcd not found. Run the hardware simulation first.")
    exit(1)

# Downsample to represent clock cycles (adjust factor based on your timescale)
cycles = range(len(toggles_per_time))

plt.figure(figsize=(12, 6))
# Using the green color for the Masked+DMR branch as requested
plt.plot(cycles, toggles_per_time, color='#388e3c', linewidth=0.8, label="Proposed Branch: Masked+DMR")

plt.title("Hardware Hamming Distance Temporal Trace", fontweight='bold')
plt.xlabel("Simulation Time (Clock Cycles)", fontweight='bold')
plt.ylabel("Hamming Distance (Toggles/Cycle)", fontweight='bold')
plt.xlim(0, 500) # Match the 0-500 cycle window
plt.ylim(0, 45)  
plt.legend(loc='upper right')
plt.grid(True, linestyle=':', alpha=0.7)

os.makedirs('graphs', exist_ok=True)
plt.savefig("graphs/real_vcd_temporal_trace.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Temporal Trace Plot saved to graphs/real_vcd_temporal_trace.png")
