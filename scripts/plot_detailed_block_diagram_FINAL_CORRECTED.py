import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

# 1. Set up the rigid canvas grid
fig, ax = plt.subplots(figsize=(14, 10))
ax.set_xlim(0, 15)
ax.set_ylim(0, 12)
ax.axis('off')

def draw_box(ax, x, y, width, height, text, facecolor, edgecolor='black', style='round,pad=0.2', text_color='black', weight='normal', ls='-'):
    box = patches.FancyBboxPatch((x, y), width, height, boxstyle=style,
                                 edgecolor=edgecolor, facecolor=facecolor, lw=2, linestyle=ls)
    ax.add_patch(box)
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=12, color=text_color, fontweight=weight, wrap=True)

def draw_arrow(ax, x1, y1, x2, y2):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1), arrowprops=dict(arrowstyle="->", lw=2, color='black'))

# 2. Draw External System Blocks
# Pushed inward by 0.5 units so their center-lines hit the flat edge, not the corners
draw_box(ax, 2.5, 10.0, 4.0, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 7.5, 10.0, 4.0, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')

draw_box(ax, 0.5, 7.5, 2.5, 1.2, "TRNG / PRNG\n(Mask m)", '#e1bee7')
draw_box(ax, 4.0, 1.0, 6.0, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')

# 3. Draw The Highlighted Proposed Core (Dashed Box)
core_bg = patches.Rectangle((3.4, 4.2), 10.4, 5.4, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)

# Title placed perfectly between the two vertical input lines (X=7.0 is the exact center)
ax.text(7.0, 9.25, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=13, fontweight='bold', color='#d32f2f')

# Internal Core Blocks (Perfectly centered at X=7.0)
draw_box(ax, 4.0, 7.5, 6.0, 1.2, "Boolean Masking\n& Hardened BRAMs", '#ffffff')
draw_box(ax, 4.0, 5.0, 6.0, 1.2, "Glitch-Mitigation\nRegister Barriers", '#ffffff')
draw_box(ax, 10.5, 5.0, 3.0, 1.2, "Dual Redundancy\nFault Comparator", '#ffffff')

# 4. Draw Connecting Arrows (Strictly orthogonal, hitting flat edges)

# Sync Data -> Masking (Center drops at X=4.5, safely inside the X=4.0 left edge)
draw_arrow(ax, 4.5, 10.0, 4.5, 8.7)

# Current Key -> Masking (Center drops at X=9.5, safely inside the X=10.0 right edge)
draw_arrow(ax, 9.5, 10.0, 9.5, 8.7)

# TRNG -> Masking (Perfect horizontal entry into the exact center of the edge)
draw_arrow(ax, 3.0, 8.1, 4.0, 8.1)

# Masking -> Glitch Mitigation (Perfect vertical drop down the center)
draw_arrow(ax, 7.0, 7.5, 7.0, 6.2)

# Glitch Mitigation -> Next Session Key (Perfect vertical drop down the center)
draw_arrow(ax, 7.0, 5.0, 7.0, 2.2)

# Glitch Mitigation output -> Fault Comparator (Perfect horizontal entry)
draw_arrow(ax, 10.0, 5.6, 10.5, 5.6)

# Fault Comparator -> Alarm (Perfect vertical drop)
draw_arrow(ax, 12.0, 5.0, 12.0, 3.6)
ax.text(12.0, 3.2, "Hardware\nFault Alarm", ha='center', va='center', fontsize=11, color='red', fontweight='bold')

# Feedback loop for rolling key (Orthogonal outer routing)
ax.plot([10.0, 14.0], [1.6, 1.6], color='black', lw=2)   # Out of Next Key right edge
ax.plot([14.0, 14.0], [1.6, 10.6], color='black', lw=2)  # Up past the entire core
draw_arrow(ax, 14.0, 10.6, 11.5, 10.6)                   # Left into Current Key State right edge

# Highlight mitigated vulnerability text
ax.text(1.7, 9.4, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 2.0, 9.0, 3.4, 8.5)

# 5. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=16, fontweight='bold', pad=15)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture_FINAL_CORRECTED.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture_FINAL_CORRECTED.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Mathematically perfect diagram saved to figures/fig_detailed_kdm_architecture_FINAL_CORRECTED.pdf")
