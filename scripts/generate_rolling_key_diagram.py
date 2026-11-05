import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

os.makedirs('diagrams_color', exist_ok=True)
os.makedirs('diagrams_mono', exist_ok=True)

def draw_diagram(is_color=True):
    fig, ax = plt.subplots(figsize=(8, 6.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 7)
    ax.axis('off')

    if is_color:
        c_reg = '#bbdefb'  # Blue for Register
        c_kdf = '#ffe0b2'  # Orange for KDF Combinational Logic
        c_out = '#c8e6c9'  # Green for Output
        c_in  = '#f5f5f5'  # Gray for Input
        c_edge = 'black'
        c_line = '#333333'
        c_leak = '#d32f2f'
    else:
        c_reg = c_kdf = c_out = c_in = 'white'
        c_edge = c_line = c_leak = 'black'

    def draw_box(x, y, text, bg_color, is_bold=False, w=3.6, h=0.9, fontsize=10):
        lw = 2.0 if is_bold else 1.2
        rect = patches.FancyBboxPatch((x - w/2, y - h/2), w, h, 
                                      boxstyle="round,pad=0.1,rounding_size=0.15", 
                                      linewidth=lw, edgecolor=c_edge, facecolor=bg_color, zorder=4)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=fontsize, family='sans-serif', 
                fontweight='bold' if is_bold else 'normal', zorder=5)

    # Draw Nodes
    draw_box(2.0, 5.8, "Sync Data / Nonce\n(v)", c_in, w=2.6, h=0.7, fontsize=9.5)
    draw_box(6.5, 5.8, "Current Key State ($K_i$)\n[Register State]", c_reg, is_bold=True, w=3.4, h=0.8)
    draw_box(6.5, 3.8, "Key Derivation Function (KDF)\n(Combinational Core)", c_kdf, is_bold=True, w=4.2, h=0.9)
    draw_box(6.5, 1.8, "Next Session Key ($K_{i+1}$)\nTo AES-GCM Datapath", c_out, w=3.8, h=0.8)

    # Clean SCA Vulnerability Callout
    ax.text(2.6, 3.8, "SCA Vulnerability Window\n(Dynamic Power Leakage)", ha='center', va='center', 
            fontsize=9.5, color=c_leak, fontweight='bold', fontstyle='italic')
    ax.annotate("", xy=(4.4, 3.8), xytext=(3.9, 3.8), 
                arrowprops=dict(arrowstyle="-|>", color=c_leak, linewidth=2, linestyle='--'))

    # Routing Lines & Arrows
    arrow_props = dict(arrowstyle="-|>", mutation_scale=15, linewidth=1.5, color=c_line, zorder=3)
    
    def dline(x1, y1, x2, y2):
        ax.plot([x1, x2], [y1, y2], color=c_line, linewidth=1.5, zorder=2)
        
    def darrow(x1, y1, x2, y2):
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1), arrowprops=arrow_props)

    # Sync Data to KDF
    dline(2.0, 5.45, 2.0, 4.2)
    dline(2.0, 4.2, 4.4, 4.2)
    darrow(4.4, 4.2, 4.4, 4.0) 

    # Key Register to KDF
    darrow(6.5, 5.35, 6.5, 4.25) 

    # KDF to Output
    darrow(6.5, 3.35, 6.5, 2.25)

    # Feedback Loop (Rolling Key Mechanism)
    dline(8.4, 1.8, 9.2, 1.8)
    dline(9.2, 1.8, 9.2, 5.8)
    darrow(9.2, 5.8, 8.2, 5.8)

    # Clock label
    ax.text(4.8, 5.8, "CLK", ha='center', va='center', fontsize=9, fontweight='bold')
    dline(5.1, 5.8, 4.8, 5.8)

    plt.tight_layout()
    prefix = "diagrams_color" if is_color else "diagrams_mono"
    plt.savefig(f"{prefix}/fig_bg_rolling_key_v2.png", dpi=300, bbox_inches='tight')
    plt.savefig(f"{prefix}/fig_bg_rolling_key_v2.pdf", bbox_inches='tight')
    plt.close()

draw_diagram(is_color=True)
draw_diagram(is_color=False)
print("SUCCESS: Professional Rolling Key diagram generated in diagrams_color/ and diagrams_mono/")
