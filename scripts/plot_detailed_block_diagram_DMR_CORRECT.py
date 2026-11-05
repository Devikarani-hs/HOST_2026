import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

# 1. Set up the rigid canvas grid
fig, ax = plt.subplots(figsize=(14, 11))
ax.set_xlim(0, 15)
ax.set_ylim(0, 12)
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
draw_box(ax, 2.5, 10.2, 4.0, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 7.5, 10.2, 4.0, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')

draw_box(ax, 0.5, 7.5, 2.5, 1.2, "TRNG / PRNG\n(Mask m)", '#e1bee7')
draw_box(ax, 4.0, 0.8, 6.0, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')

# 3. Draw The Highlighted Proposed Core (Dashed Box)
core_bg = patches.Rectangle((3.2, 3.8), 10.8, 5.8, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)

# Title placed safely at the top center of the core box
ax.text(8.6, 9.3, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=12, fontweight='bold', color='#d32f2f')

# 4. Draw Internal Core Blocks (Showing DMR Parallel Branches)
draw_box(ax, 4.0, 7.8, 6.0, 1.1, "Boolean Masking & Hardened BRAMs\n(Shared / Duplicated)", '#ffffff')

# Split into DMR Branch A and Branch B
draw_box(ax, 4.0, 6.0, 2.8, 1.0, "Register Barrier\n(Branch A)", '#ffffff')
draw_box(ax, 7.2, 6.0, 2.8, 1.0, "Register Barrier\n(Branch B)", '#ffffff')

# Dual Redundancy Fault Comparator
draw_box(ax, 10.5, 5.2, 3.0, 1.4, "Dual Redundancy\nFault Comparator\n($Out_A == Out_B$)", '#ffffff')

# 5. Draw Connecting Arrows (Strictly Orthogonal)

# Sync Data & Current Key -> Masking
draw_arrow(ax, 4.5, 10.2, 4.5, 8.9)
draw_arrow(ax, 9.5, 10.2, 9.5, 8.9)

# TRNG -> Masking
draw_arrow(ax, 3.0, 8.1, 4.0, 8.1)

# Masking -> Split into Branch A and Branch B
ax.plot([7.0, 7.0], [7.8, 7.5], color='black', lw=2)
ax.plot([5.4, 8.6], [7.5, 7.5], color='black', lw=2)
draw_arrow(ax, 5.4, 7.5, 5.4, 7.0) # Into Branch A
draw_arrow(ax, 8.6, 7.5, 8.6, 7.0) # Into Branch B

# Branch A -> Next Session Key (Main Datapath)
draw_arrow(ax, 5.4, 6.0, 5.4, 2.0)
ax.plot([5.4, 7.0], [2.0, 2.0], color='black', lw=2)
draw_arrow(ax, 7.0, 2.0, 7.0, 2.0) # Merge into Next Session Key entry

# Branch A output -> Comparator Input 1
ax.plot([5.4, 5.4], [5.5, 5.5], color='black', lw=2) # Tapped from Branch A
# Let's route cleanly to the comparator
ax.plot([5.4, 5.4], [4.6, 4.6], color='black', lw=2)
ax.plot([5.4, 10.5], [4.6, 4.6], color='black', lw=2)
draw_arrow(ax, 10.5, 4.6, 10.5, 5.2)

# Branch B output -> Comparator Input 2
ax.plot([8.6, 8.6], [5.5, 4.9], color='black', lw=2)
ax.plot([8.6, 11.5], [4.9, 4.9], color='black', lw=2)
draw_arrow(ax, 11.5, 4.9, 11.5, 5.2)

# Comparator -> Alarm
draw_arrow(ax, 12.0, 5.2, 12.0, 4.2)
ax.text(12.0, 3.9, "Hardware\nFault Alarm", ha='center', va='center', fontsize=10, color='red', fontweight='bold')

# Feedback loop for rolling key
ax.plot([10.0, 13.5], [1.4, 1.4], color='black', lw=2)   # Out of Next Key right edge
ax.plot([13.5, 13.5], [1.4, 10.8], color='black', lw=2)  # Up past the entire core
draw_arrow(ax, 13.5, 10.8, 11.5, 10.8)                   # Left into Current Key State

# Highlight mitigated vulnerability text
ax.text(1.7, 9.4, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 2.0, 9.0, 3.2, 8.5)

# 6. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=16, fontweight='bold', pad=15)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture_DMR_CORRECT.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture_DMR_CORRECT.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] DMR-corrected block diagram saved to figures/fig_detailed_kdm_architecture_DMR_CORRECT.pdf")
