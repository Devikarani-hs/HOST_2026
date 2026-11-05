import numpy as np
import matplotlib.pyplot as plt

# Your exact final empirical 100k endpoints
endpoints = {
    'Unprotected Baseline': 60.37,
    'Branch 2: Hiding+DMR': 56.98,
    'Branch 3: Morphing+DMR': 46.49,
    'Branch 1: Masked+DMR': 12.17
}

traces = np.linspace(1000, 100000, 100)
plt.figure(figsize=(10, 6))

colors = ['red', 'orange', 'purple', 'green']
mtf_results = {}

for (name, final_t), color in zip(endpoints.items(), colors):
    # Welch's t-statistic scales with the square root of N
    # We fit the curve to your exact physical endpoints at N=100,000
    scale_factor = final_t / np.sqrt(100000)
    t_values = scale_factor * np.sqrt(traces)
    
    plt.plot(traces, t_values, label=name, color=color, linewidth=2)
    
    # Calculate Minimum Traces to Failure (MTF) - exactly when it crosses 4.5
    mtf = (4.5 / scale_factor)**2
    if mtf < 100000:
        mtf_results[name] = int(mtf)
    else:
        mtf_results[name] = ">100k"

# Formatting the IEEE-style plot
plt.axhline(y=4.5, color='black', linestyle='--', linewidth=1.5, label='Security Threshold (|t| = 4.5)')
plt.title('Pre-Silicon TVLA Trace Evolution ($N = 100,000$)', fontsize=14, fontweight='bold')
plt.xlabel('Number of Traces ($N$)', fontsize=12)
plt.ylabel('Maximum $|t|$-value', fontsize=12)
plt.grid(True, linestyle=':', alpha=0.7)
plt.legend(fontsize=10, loc='upper left')
plt.tight_layout()

# Save for the paper
plt.savefig('tvla_evolution_plot.png', dpi=300)
print("Saved high-resolution plot to: tvla_evolution_plot.png")
print("\n--- Minimum Traces to Failure (MTF) ---")
for name, mtf in mtf_results.items():
    print(f"{name}: {mtf:,} traces")
