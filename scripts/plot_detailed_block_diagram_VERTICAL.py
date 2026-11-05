import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

# 1. Set up the figure canvas
fig, ax = plt.subplots(figsize=(12, 10))
ax.set_xlim(0, 12)
ax.set_ylim(0, 11)
ax.axis('off')

def draw_box(ax, x, y, width, height, text, facecolor, edgecolor='black', style='round,pad=0.2', text_color='black', weight='normal', ls='-'):
    box = patches.FancyBboxPatch((x, y), width, height, boxstyle=style,
                                 edgecolor=edgecolor, facecolor=facecolor, lw=2, linestyle=ls)
    ax.add_patch(box)
    ax.text(x + width/2, y + height/2, text, ha='center', va='center',
            fontsize=11, color=text_color, fontweight=weight, wrap=True)

def draw_arrow(ax, x1, y1, x2, y2):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1), arrowprops=dict(arrowstyle="->", lw=2, color='black'))

# 2. Draw External System Blocks
draw_box(ax, 2.0, 9.0, 3.0, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 7.0, 9.0, 4.0, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')
draw_box(ax, 0.5, 6.5, 2.0, 1.0, "TRNG / PRNG\n(Mask m)", '#e1bee7')
draw_box(ax, 4.0, 1.5, 4.0, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')

# 3. Draw The Highlighted Proposed Core (Dashed Box)
core_bg = patches.Rectangle((2.8, 3.5), 8.5, 5.0, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)
ax.text(7.05, 8.8, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=12, fontweight='bold', color='#d32f2f')

# Internal Core Blocks (Aligned perfectly on x=6.0 center axis)
draw_box(ax, 4.0, 6.5, 4.0, 1.0, "Boolean Masking\n& Hardened BRAMs", '#ffffff')
draw_box(ax, 4.0, 4.5, 4.0, 1.0, "Glitch-Mitigation\nRegister Barriers", '#ffffff')
draw_box(ax, 8.5, 4.5, 2.5, 1.0, "Dual Redundancy\nFault Comparator", '#ffffff')

# 4. Draw Connecting Arrows (Vertical Flow)

# Sync Data -> Masking
ax.plot([3.5, 3.5], [9.0, 8.0], color='black', lw=2)
ax.plot([3.5, 5.0], [8.0, 8.0], color='black', lw=2)
draw_arrow(ax, 5.0, 8.0, 5.0, 7.5)

# Current Key -> Masking
ax.plot([9.0, 9.0], [9.0, 8.0], color='black', lw=2)
ax.plot([9.0, 7.0], [8.0, 8.0], color='black', lw=2)
draw_arrow(ax, 7.0, 8.0, 7.0, 7.5)

# TRNG -> Masking
draw_arrow(ax, 2.5, 7.0, 4.0, 7.0)

# Masking -> Glitch Mitigation (Straight down!)
draw_arrow(ax, 6.0, 6.5, 6.0, 5.5)

# Glitch Mitigation -> Next Session Key (Straight down!)
draw_arrow(ax, 6.0, 4.5, 6.0, 2.7)

# Glitch Mitigation output -> Fault Comparator
ax.plot([6.0, 8.0], [3.5, 3.5], color='black', lw=2)
ax.plot([8.0, 8.0], [3.5, 5.0], color='black', lw=2)
draw_arrow(ax, 8.0, 5.0, 8.5, 5.0)

# Fault Comparator -> Alarm
ax.plot([9.75, 9.75], [4.5, 3.8], color='black', lw=2)
draw_arrow(ax, 9.75, 3.8, 9.75, 3.5)
ax.text(9.75, 3.2, "Hardware\nFault Alarm", ha='center', va='center', fontsize=10, color='red', fontweight='bold')

# Feedback loop for rolling key (Straight routing)
ax.plot([8.0, 11.5], [2.1, 2.1], color='black', lw=2) # Out of Next Key right
ax.plot([11.5, 11.5], [2.1, 9.6], color='black', lw=2) # Up
draw_arrow(ax, 11.5, 9.6, 11.0, 9.6) # Left into Current Key State

# Highlight mitigated vulnerability text
ax.text(1.2, 8.2, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 1.5, 7.8, 2.8, 7.2)

# 5. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=15, fontweight='bold', pad=20)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture_VERTICAL.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture_VERTICAL.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Vertical pipeline architecture saved to figures/fig_detailed_kdm_architecture_VERTICAL.pdf")
