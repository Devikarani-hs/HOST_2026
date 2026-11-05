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

def draw_arrow(ax, x1, y1, x2, y2):
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1), arrowprops=dict(arrowstyle="->", lw=2, color='black'))

# 2. Draw External System Blocks
draw_box(ax, 2.0, 8, 3.0, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 7.5, 8, 4.0, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')
draw_box(ax, 4.25, 1.0, 4.0, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')
draw_box(ax, 0.2, 5.0, 1.8, 1.0, "TRNG / PRNG\n(Mask m)", '#e1bee7')

# 3. Draw The Highlighted Proposed Core
# Dashed bounding box (Lowered slightly to avoid top lines)
core_bg = patches.Rectangle((2.5, 3.5), 7.5, 3.5, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)
# Title placed safely ABOVE the dashed box
ax.text(6.25, 7.25, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=12, fontweight='bold', color='#d32f2f')

# Internal Blocks (Perfectly spaced)
draw_box(ax, 3.0, 5.0, 2.8, 1.0, "Boolean Masking\n& Hardened BRAMs", '#ffffff')
draw_box(ax, 6.7, 5.0, 2.8, 1.0, "Glitch-Mitigation\nRegister Barriers", '#ffffff')
draw_box(ax, 4.85, 3.8, 2.8, 0.8, "Dual Redundancy\nFault Comparator", '#ffffff')

# 4. Draw Connecting Arrows (Symmetric Routing)

# Sync Data -> Boolean Masking (Straight vertical drop)
ax.plot([3.5, 3.5], [8.0, 6.0], color='black', lw=2)
draw_arrow(ax, 3.5, 6.0, 3.5, 6.0) # Arrowhead at border

# Current Key -> Boolean Masking
ax.plot([9.5, 9.5], [8.0, 6.6], color='black', lw=2) # Drop down
ax.plot([9.5, 5.2], [6.6, 6.6], color='black', lw=2) # Go left (above the box)
ax.plot([5.2, 5.2], [6.6, 6.0], color='black', lw=2) # Drop into masking
draw_arrow(ax, 5.2, 6.0, 5.2, 6.0)

# TRNG -> Masking (Straight horizontal)
ax.plot([2.0, 3.0], [5.5, 5.5], color='black', lw=2)
draw_arrow(ax, 3.0, 5.5, 3.0, 5.5)

# Masking -> Barriers (Straight horizontal)
ax.plot([5.8, 6.7], [5.5, 5.5], color='black', lw=2)
draw_arrow(ax, 6.7, 5.5, 6.7, 5.5)

# Barriers -> Next Session Key
ax.plot([8.1, 8.1], [5.0, 3.0], color='black', lw=2) # Drop down past comparator
ax.plot([8.1, 6.25], [3.0, 3.0], color='black', lw=2) # Go left to center
ax.plot([6.25, 6.25], [3.0, 2.2], color='black', lw=2) # Drop into Next Key
draw_arrow(ax, 6.25, 2.2, 6.25, 2.2)

# Barriers -> Fault Comparator
ax.plot([8.1, 7.65], [4.2, 4.2], color='black', lw=2)
draw_arrow(ax, 7.65, 4.2, 7.65, 4.2)

# Fault Comparator -> Alarm
ax.plot([4.85, 2.5], [4.2, 4.2], color='black', lw=2)
draw_arrow(ax, 2.5, 4.2, 2.5, 4.2)
ax.text(1.5, 4.2, "Hardware\nFault Alarm", ha='center', va='center', fontsize=10, color='red', fontweight='bold')

# Feedback loop for rolling key
ax.plot([8.25, 11.8], [1.6, 1.6], color='black', lw=2) # Out of Next Key, far right
ax.plot([11.8, 11.8], [1.6, 8.6], color='black', lw=2) # Straight up
ax.plot([11.8, 11.5], [8.6, 8.6], color='black', lw=2) # Left into Current Key
draw_arrow(ax, 11.5, 8.6, 11.5, 8.6)

# Highlight mitigated vulnerability text
ax.text(1.2, 6.8, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 1.5, 6.4, 2.5, 6.0)

# 5. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=14, fontweight='bold', pad=20)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture_SYMMETRIC.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture_SYMMETRIC.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Symmetric, production-ready block diagram saved to figures/fig_detailed_kdm_architecture_SYMMETRIC.pdf")
