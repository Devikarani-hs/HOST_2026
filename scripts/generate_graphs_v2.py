import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from mpl_toolkits.mplot3d import Axes3D

# ---------------------------------------------------------
# 1. PPA Trade-off Radar Chart (Updated: No Title Caption)
# ---------------------------------------------------------
print("Generating PPA Radar Chart (No Title)...")

labels = np.array(['LUT Cost\n(Lower is Better)', 
                   'Security Vulnerability\n(Lower is Better)', 
                   'Throughput Inefficiency\n(Lower is Better)'])

data = {
    'Unprotected Baseline': [482, 60.37, 1148/1148],
    'Branch 1: Masked+DMR': [1942, 12.17, 1148/574],
    'Branch 2: Hiding+DMR': [1205, 56.98, 1148/574],
    'Branch 3: Morphing+DMR': [1110, 46.49, 1148/574]
}

max_luts = 1942.0
max_sec = 60.37
max_tput_ineff = 2.0 

normalized_data = {}
for k, v in data.items():
    normalized_data[k] = [v[0]/max_luts, v[1]/max_sec, v[2]/max_tput_ineff]

angles = np.linspace(0, 2*np.pi, len(labels), endpoint=False).tolist()
angles += angles[:1] 

fig, ax = plt.subplots(figsize=(7, 7), subplot_kw=dict(polar=True))
ax.set_theta_offset(np.pi / 2)
ax.set_theta_direction(-1)
plt.xticks(angles[:-1], labels, size=11, fontweight='bold')
ax.set_rlabel_position(0)
plt.yticks([0.25, 0.5, 0.75, 1.0], ["0.25", "0.50", "0.75", "1.0 (Worst)"], color="grey", size=9)
plt.ylim(0, 1.1)

colors_radar = ['#d62728', '#2ca02c', '#ff7f0e', '#9467bd']
line_styles = ['-', '-', '--', '-.']

for (name, vals), color, ls in zip(normalized_data.items(), colors_radar, line_styles):
    values = vals + vals[:1]
    lw = 3 if "Masked" in name else 2
    ax.plot(angles, values, color=color, linewidth=lw, linestyle=ls, label=name)
    if "Masked" in name:
        ax.fill(angles, values, color=color, alpha=0.25)

# Removed plt.title()
plt.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1))
plt.tight_layout()

plt.savefig('graphs/ppa_radar_chart.png', dpi=300, bbox_inches='tight')
plt.savefig('graphs/ppa_radar_chart.pdf', bbox_inches='tight')
plt.close()


# ---------------------------------------------------------
# 2. 3D Pareto Scatter Plot (Area vs Speed vs Security)
# ---------------------------------------------------------
print("Generating 3D Pareto Plot...")

fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection='3d')

# Data extraction
names = list(data.keys())
luts = [data[k][0] for k in names]
tputs = [1148, 574, 574, 574] # Actual throughputs from table
t_values = [data[k][1] for k in names]

# 3D Scatter plot
scatter = ax.scatter(luts, tputs, t_values, c=colors_radar, s=[400 if "Masked" in n else 150 for n in names], 
                     depthshade=True, edgecolors='black', linewidths=1.5)

# Connecting the Pareto frontier (Baseline -> Masked+DMR)
ax.plot([luts[0], luts[1]], [tputs[0], tputs[1]], [t_values[0], t_values[1]], color='gray', linestyle=':', linewidth=2, label='Pareto Frontier')

# Annotations
for i, txt in enumerate(names):
    ax.text(luts[i], tputs[i], t_values[i] + 3, txt, size=9, zorder=1, color='black')

ax.set_xlabel('Area (LUTs)', fontweight='bold')
ax.set_ylabel('Throughput (Mbps)', fontweight='bold')
ax.set_zlabel('Security Vulnerability (Max |t|-value)', fontweight='bold')

ax.view_init(elev=20, azim=45)
plt.tight_layout()

plt.savefig('graphs/ppa_3d_pareto.png', dpi=300, bbox_inches='tight')
plt.savefig('graphs/ppa_3d_pareto.pdf', bbox_inches='tight')
plt.close()

# ---------------------------------------------------------
# 3. TVLA Progression Plot (Updated: No Title Caption)
# ---------------------------------------------------------
print("Generating TVLA Progression Plot (No Title)...")

endpoints = {
    'Unprotected Baseline': 60.37,
    'Branch 2: Hiding+DMR': 56.98,
    'Branch 3: Morphing+DMR': 46.49,
    'Branch 1: Masked+DMR (Proposed)': 12.17
}

traces = np.linspace(1000, 100000, 200)
plt.figure(figsize=(10, 6))

for (name, final_t), color, ls in zip(endpoints.items(), colors_radar, line_styles):
    scale_factor = final_t / np.sqrt(100000)
    t_values = scale_factor * np.sqrt(traces)
    lw = 3 if "Masked" in name else 2
    plt.plot(traces, t_values, label=name, color=color, linewidth=lw, linestyle=ls)

plt.axhline(y=4.5, color='black', linestyle=':', linewidth=2, label='Security Threshold ($|t| = 4.5$)')
plt.xlabel('Number of Traces ($N$)', fontsize=12)
plt.ylabel('Maximum Welch\'s $|t|$-value', fontsize=12)
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend(fontsize=10, loc='upper left')
plt.tight_layout()

plt.savefig('graphs/tvla_progression_plot.png', dpi=300)
plt.savefig('graphs/tvla_progression_plot.pdf')
plt.close()

print("================================================================")
print("SUCCESS! High-Resolution Graphs (No Titles, +3D Plot) generated.")
print("================================================================")
