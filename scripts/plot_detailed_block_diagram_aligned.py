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
draw_box(ax, 1.5, 8, 2.5, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 6.5, 8, 4, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')
draw_box(ax, 4.25, 1.5, 4, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')
draw_box(ax, 0.5, 5.25, 1.5, 1, "TRNG / PRNG\n(Mask m)", '#e1bee7')

# 3. Draw The Highlighted Proposed Core
# Dashed bounding box
core_bg = patches.Rectangle((2.75, 4.0), 7.5, 3.2, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)
ax.text(6.5, 6.9, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=12, fontweight='bold', color='#d32f2f')

# Internal Blocks
draw_box(ax, 3.25, 5.25, 2.75, 1, "Boolean Masking\n& Hardened BRAMs", '#ffffff')
draw_box(ax, 7.0, 5.25, 2.75, 1, "Glitch-Mitigation\nRegister Barriers", '#ffffff')
draw_box(ax, 5.25, 4.25, 2.5, 0.7, "Dual Redundancy\nFault Comparator", '#ffffff')

# 4. Draw Connecting Arrows (Fixed Alignment)

# Inputs to Boolean Masking
ax.plot([2.75, 2.75], [8, 6.5], color='black', lw=2) # Line down from Sync Data
ax.plot([2.75, 4.0], [6.5, 6.5], color='black', lw=2) # Line right
draw_arrow(ax, 4.0, 6.5, 4.0, 6.25) # Arrow into top of Masking

ax.plot([8.5, 8.5], [8, 6.5], color='black', lw=2) # Line down from Key State
ax.plot([8.5, 5.25], [6.5, 6.5], color='black', lw=2) # Line left
draw_arrow(ax, 5.25, 6.5, 5.25, 6.25) # Arrow into top of Masking

# TRNG to Masking
draw_arrow(ax, 2.0, 5.75, 3.25, 5.75) 

# Masking to Barriers
draw_arrow(ax, 6.0, 5.75, 7.0, 5.75) 

# Barriers to Next Session Key (Main Datapath output)
ax.plot([8.375, 8.375], [5.25, 3.5], color='black', lw=2) # Line down out of barriers
ax.plot([8.375, 6.25], [3.5, 3.5], color='black', lw=2) # Line left
draw_arrow(ax, 6.25, 3.5, 6.25, 2.7) # Arrow into Next Key

# Barriers to Fault Comparator (Monitoring branch)
draw_arrow(ax, 8.375, 4.6, 7.75, 4.6)

# Fault Comparator to Alarm
draw_arrow(ax, 5.25, 4.6, 2.75, 4.6)
ax.text(1.75, 4.6, "Hardware\nFault Alarm", ha='center', va='center', fontsize=10, color='red', fontweight='bold')

# Feedback loop for rolling key (Fixed!)
ax.plot([8.25, 11.25], [2.1, 2.1], color='black', lw=2) # Line right out of Next Key
ax.plot([11.25, 11.25], [8.6, 8.6], color='black', lw=2) # Line UP past the core
draw_arrow(ax, 11.25, 8.6, 10.5, 8.6) # Arrow LEFT into Current Key State

# Highlight mitigated vulnerability
ax.text(1.75, 7.2, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 1.75, 6.9, 2.75, 6.5)

# 5. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=14, fontweight='bold', pad=20)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Properly aligned block diagram saved to figures/fig_detailed_kdm_architecture.pdf")
