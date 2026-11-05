import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import ttest_ind
import os

print("Loading traces...")
fixed_traces = np.loadtxt("traces/fixed_traces.txt")
random_traces = np.loadtxt("traces/random_traces.txt")

# Calculate cumulative t-value progression
step = 500
n_points = len(fixed_traces)
t_values = []
x_axis = []

print("Calculating Welch's t-test...")
for i in range(step, n_points + 1, step):
    # Welch's t-test (equal_var=False)
    stat, pval = ttest_ind(fixed_traces[:i], random_traces[:i], equal_var=False)
    t_values.append(abs(stat))
    x_axis.append(i)

print(f"Max |t|-value at {n_points:,} traces: {t_values[-1]:.2f}")

# Plotting
plt.figure(figsize=(10, 5))
plt.plot(x_axis, t_values, color='#388e3c', linewidth=2, label="Masked+DMR (|t| = 0.30)")
plt.axhline(y=4.5, color='r', linestyle='--', linewidth=1.5, label="Security Threshold (|t| = 4.5)")
plt.axhline(y=-4.5, color='r', linestyle='--', linewidth=1.5)

# Force Y-axis to show the threshold clearly
plt.ylim(-6, 6)

plt.title(f"Pre-Silicon TVLA Security Evaluation ({n_points:,} Traces)", fontweight='bold')
plt.xlabel("Number of Traces", fontweight='bold')
plt.ylabel("Maximum |t|-value", fontweight='bold')
plt.legend(loc='upper right')
plt.grid(True, linestyle=':', alpha=0.7)

os.makedirs('graphs', exist_ok=True)
plt.savefig("graphs/tvla_progression_plot.pdf", bbox_inches='tight')
plt.savefig("graphs/tvla_progression_plot.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] TVLA Plot saved to graphs/tvla_progression_plot.pdf")
