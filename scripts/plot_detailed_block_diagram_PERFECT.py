import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

# 1. Set up the figure canvas
fig, ax = plt.subplots(figsize=(12, 10))
ax.set_xlim(0, 12.5)
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
draw_box(ax, 3.0, 8.5, 2.5, 1.2, "Sync Data / Nonce\n(v)", '#f0f0f0')
draw_box(ax, 6.5, 8.5, 4.0, 1.2, "Current Key State ($K_i$)\n[Register State]", '#cce5ff', weight='bold')
draw_box(ax, 0.0, 6.0, 2.0, 1.0, "TRNG / PRNG\n(Mask m)", '#e1bee7')
draw_box(ax, 3.0, 1.5, 6.0, 1.2, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", '#c8e6c9')

# 3. Draw The Highlighted Proposed Core (Dashed Box)
core_bg = patches.Rectangle((2.5, 3.0), 9.7, 4.8, linewidth=2.5, edgecolor='#d32f2f', facecolor='#ffe0b2', linestyle='--', alpha=0.3)
ax.add_patch(core_bg)
# Title placed safely ABOVE the dashed box
ax.text(7.35, 8.1, "Proposed Focus: Masked+DMR Key Derivation Module", ha='center', va='center', fontsize=12, fontweight='bold', color='#d32f2f')

# Internal Core Blocks (Expanded width to allow straight vertical drops)
draw_box(ax, 3.0, 6.0, 6.0, 1.0, "Boolean Masking & Hardened BRAMs", '#ffffff')
draw_box(ax, 3.0, 4.0, 6.0, 1.0, "Glitch-Mitigation Register Barriers", '#ffffff')
draw_box(ax, 9.6, 4.0, 2.3, 1.0, "Dual Redundancy\nFault Comparator", '#ffffff')

# 4. Draw Connecting Arrows (100% Straight, NO horizontal crossing lines)

# Sync Data -> Masking (Perfectly straight vertical)
draw_arrow(ax, 4.25, 8.5, 4.25, 7.0)

# Current Key -> Masking (Perfectly straight vertical)
draw_arrow(ax, 8.5, 8.5, 8.5, 7.0)

# TRNG -> Masking (Perfectly straight horizontal)
draw_arrow(ax, 2.0, 6.5, 3.0, 6.5)

# Masking -> Glitch Mitigation (Perfectly straight vertical)
draw_arrow(ax, 6.0, 6.0, 6.0, 5.0)

# Glitch Mitigation -> Next Session Key (Perfectly straight vertical)
draw_arrow(ax, 6.0, 4.0, 6.0, 2.7)

# Glitch Mitigation output -> Fault Comparator (Perfectly straight horizontal)
draw_arrow(ax, 9.0, 4.5, 9.6, 4.5)

# Fault Comparator -> Alarm (Perfectly straight vertical)
draw_arrow(ax, 10.75, 4.0, 10.75, 3.2)
ax.text(10.75, 2.8, "Hardware\nFault Alarm", ha='center', va='center', fontsize=10, color='red', fontweight='bold')

# Feedback loop for rolling key (Orthogonal right-side routing)
ax.plot([9.0, 12.0], [2.1, 2.1], color='black', lw=2)  # Out of Next Key
ax.plot([12.0, 12.0], [2.1, 9.1], color='black', lw=2) # Up past the entire core
draw_arrow(ax, 12.0, 9.1, 10.5, 9.1)                   # Left into Current Key State

# Highlight mitigated vulnerability text
ax.text(1.2, 7.7, "SCA / FI Vulnerabilities\nMitigated Internally", ha='center', va='center', fontsize=11, color='#d32f2f', fontweight='bold', style='italic')
draw_arrow(ax, 1.5, 7.3, 2.5, 6.8)

# 5. Save Outputs
plt.title("Detailed Architecture: Proposed Masked+DMR KDF", fontsize=15, fontweight='bold', pad=20)
os.makedirs('figures', exist_ok=True)
plt.savefig("figures/fig_detailed_kdm_architecture_PERFECT.pdf", bbox_inches='tight')
plt.savefig("figures/fig_detailed_kdm_architecture_PERFECT.png", dpi=300, bbox_inches='tight')
print("[SUCCESS] Mathematically perfect diagram saved to figures/fig_detailed_kdm_architecture_PERFECT.pdf")
