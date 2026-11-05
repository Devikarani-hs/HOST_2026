import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

# 1. Set up the figure canvas
fig, ax = plt.subplots(figsize=(12, 9))
ax.set_xlim(0, 12)
ax.set_ylim(0, 10)
ax.axis('off')

def draw_box(ax, x, y, width, height, text, facecolor, edgecolor='black', style='round,pad=0.2', text_color='black', weight='normal', ls='-'):
    box = patches.FancyBboxPatch((x, y), width, height, boxstyle=style,
                                 edgecolor=edgecolor, facecolor=facecolor, lw=2, linestyle=ls)
    ax.add_patch(box)
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=11, color=text_color, fontweight=weight, wrap=True)

# 2. Draw External System Blocks (matching your original colors)
draw_box(ax, 1, 8, 3, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 7, 8, 4, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')
draw_box(ax, 4.5, 1, 4, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')
draw_box(ax, 0.5, 5, 1.5, 1, "TRNG / PRNG\n(Mask m)", '#e1bee7')

# 3. Draw The Highlighted Proposed Core (Expanding the KDF)
# Dashed bounding box for the proposed work
core_bg = patches.Rectangle((2.5, 3.5), 7, 3.5, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)
ax.text(6, 6.7, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=12, fontweight='bold', color='#d32f2f')

# Sub-blocks inside the proposed core
draw_box(ax, 3, 5, 2.5, 1, "Boolean Masking\n& Hardened BRAMs", '#ffffff')
draw_box(ax, 6.5, 5, 2.5, 1, "Glitch-Mitigation\nRegister Barriers", '#ffffff')
draw_box(ax, 4.75, 3.75, 2.5, 0.8, "Dual Redundancy\nFault Comparator", '#ffffff')

# 4. Draw Connecting Arrows
def draw_arrow(ax, x1, y1, x2, y2):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1), arrowprops=dict(arrowstyle="->", lw=2, color='black'))

# Inputs to Core
ax.plot([2.5, 2.5], [8, 6.5], color='black', lw=2)
ax.plot([2.5, 4.25], [6.5, 6.5], color='black', lw=2)
draw_arrow(ax, 4.25, 6.5, 4.25, 6)

ax.plot([9, 9], [8, 6.5], color='black', lw=2)
ax.plot([9, 7.75], [6.5, 6.5], color='black', lw=2)
draw_arrow(ax, 7.75, 6.5, 7.75, 6)

draw_arrow(ax, 2.0, 5.5, 3.0, 5.5) # PRNG to Masking

# Internal Core Routing
draw_arrow(ax, 5.5, 5.5, 6.5, 5.5) # Masking to Barriers
ax.plot([7.75, 7.75], [5, 4.15], color='black', lw=2)
draw_arrow(ax, 7.75, 4.15, 7.25, 4.15) # Barriers to Comparator

# Outputs from Core
draw_arrow(ax, 6, 3.75, 6, 2.2) # Core to Next Key

# Hardware Fault Alarm Output
draw_arrow(ax, 4.75, 4.15, 2.5, 4.15)
ax.text(1.5, 4.15, "Hardware\nFault Alarm", ha='center', va='center', fontsize=10, color='red', fontweight='bold')

# Feedback loop for rolling key
ax.plot([8.5, 11.5], [1.6, 1.6], color='black', lw=2)
ax.plot([11.5, 11.5], [8.6, 8.6], color='black', lw=2)
draw_arrow(ax, 11.5, 8.6, 11, 8.6)

# Highlight mitigated vulnerability
ax.text(2.0, 7.2, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 2.0, 6.9, 2.5, 6.0)

# 5. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=14, fontweight='bold', pad=20)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Detailed Block Diagram saved to figures/fig_detailed_kdm_architecture.pdf")
