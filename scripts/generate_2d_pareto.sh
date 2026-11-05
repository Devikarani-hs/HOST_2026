#!/bin/bash
mkdir -p graphs

cat << 'PY_EOF' > scripts/generate_2d_pareto.py
import matplotlib.pyplot as plt

# Raw Data: [LUTs, |t|-value, Throughput]
data = {
    'Unprotected Baseline': [482, 60.37, 1148],
    'Branch 1: Masked+DMR': [1942, 12.17, 574],
    'Branch 2: Hiding+DMR': [1205, 56.98, 574],
    'Branch 3: Morphing+DMR': [1110, 46.49, 574]
}

colors = ['#d62728', '#2ca02c', '#ff7f0e', '#9467bd']
markers = ['o', 's', '^', 'D']

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# --- Plot 1: Area vs Security ---
for (name, vals), color, marker in zip(data.items(), colors, markers):
    ax1.scatter(vals[0], vals[1], color=color, marker=marker, s=150, label=name, edgecolors='black', zorder=3)

# Pareto Frontier Line
ax1.plot([data['Unprotected Baseline'][0], data['Branch 1: Masked+DMR'][0]], 
         [data['Unprotected Baseline'][1], data['Branch 1: Masked+DMR'][1]], 
         color='gray', linestyle='--', linewidth=2, label='Pareto Frontier', zorder=2)

ax1.set_xlabel('Area (LUTs)', fontweight='bold')
ax1.set_ylabel('Security Vulnerability (Max |t|-value)', fontweight='bold')
ax1.grid(True, linestyle=':', alpha=0.7, zorder=1)
ax1.set_xlim(300, 2100)
ax1.axhline(y=4.5, color='black', linestyle=':', label='Threshold (|t|=4.5)')

# --- Plot 2: Throughput vs Security ---
for (name, vals), color, marker in zip(data.items(), colors, markers):
    ax2.scatter(vals[2], vals[1], color=color, marker=marker, s=150, edgecolors='black', zorder=3)

# Pareto Frontier Line
ax2.plot([data['Unprotected Baseline'][2], data['Branch 1: Masked+DMR'][2]], 
         [data['Unprotected Baseline'][1], data['Branch 1: Masked+DMR'][1]], 
         color='gray', linestyle='--', linewidth=2, zorder=2)

ax2.set_xlabel('Throughput (Mbps)', fontweight='bold')
ax2.set_ylabel('Security Vulnerability (Max |t|-value)', fontweight='bold')
ax2.grid(True, linestyle=':', alpha=0.7, zorder=1)
ax2.set_xlim(400, 1300)
ax2.axhline(y=4.5, color='black', linestyle=':')

# --- Single Legend for Both Plots ---
handles, labels = ax1.get_legend_handles_labels()
fig.legend(handles, labels, loc='upper center', bbox_to_anchor=(0.5, 1.05), ncol=3, fontsize=11, frameon=False)

plt.tight_layout()
plt.subplots_adjust(top=0.85) # Make room for legend

plt.savefig('graphs/ppa_2d_pareto_subplots.png', dpi=300, bbox_inches='tight')
plt.savefig('graphs/ppa_2d_pareto_subplots.pdf', bbox_inches='tight')
print("SUCCESS: 2D Pareto Subplots generated in graphs/ppa_2d_pareto_subplots.png")
PY_EOF

chmod +x scripts/generate_2d_pareto.py
python3 scripts/generate_2d_pareto.py
