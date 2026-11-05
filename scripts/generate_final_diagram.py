import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

os.makedirs('diagrams_color', exist_ok=True)
os.makedirs('diagrams_mono', exist_ok=True)

def draw_diagram(is_color=True):
    fig, ax = plt.subplots(figsize=(11, 7.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(1.5, 10)
    ax.axis('off')

    # Define strict color palette
    if is_color:
        c_bg_0 = '#ffcdd2' # Red
        c_bg_1 = '#c8e6c9' # Green
        c_bg_2 = '#ffe0b2' # Orange
        c_bg_3 = '#e1bee7' # Purple
        c_bg_out = '#e3f2fd' # Blue
        c_bg_in = '#f5f5f5' # Light Gray
        c_edge = 'black'
        c_arr_in = 'gray'
        c_arr_out = 'gray'
        c_arr_0 = '#d32f2f'
        c_arr_1 = '#388e3c'
        c_arr_2 = '#f57c00'
        c_arr_3 = '#7b1fa2'
    else:
        c_bg_0 = c_bg_1 = c_bg_2 = c_bg_3 = c_bg_out = c_bg_in = 'white'
        c_edge = 'black'
        c_arr_in = c_arr_out = c_arr_0 = c_arr_1 = c_arr_2 = c_arr_3 = 'black'

    box_w = 4.2
    box_h = 1.0
    
    # Helper to draw standardized blocks
    def draw_box(x, y, text, bg_color, is_bold=False, h=box_h, w=box_w, fontsize=10):
        lw = 2.5 if is_bold else 1.0
        rect = patches.FancyBboxPatch((x - w/2, y - h/2), w, h, 
                                      boxstyle="round,pad=0.1,rounding_size=0.15", 
                                      linewidth=lw, edgecolor=c_edge, facecolor=bg_color, zorder=4)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=fontsize, family='sans-serif', 
                fontweight='bold' if is_bold else 'normal', zorder=5)

    # 1. Draw Dashed Cluster Box for Design Space
    rect_cluster = patches.Rectangle((0.2, 3.6), 9.6, 4.8, linewidth=1.5, edgecolor='gray' if is_color else 'black', facecolor='none', linestyle='--', zorder=1)
    ax.add_patch(rect_cluster)
    ax.text(5.0, 8.0, "Design Space Exploration\n(Evaluated Countermeasure Branches)", 
            ha='center', va='center', fontsize=12, fontweight='bold', family='sans-serif', zorder=2)

    # 2. Draw All Nodes
    draw_box(5.0, 9.4, "AXI4-Stream Input Data (v)", c_bg_in, is_bold=True, h=0.6, w=4.2, fontsize=11)
    draw_box(2.8, 6.8, "1. Unprotected Baseline\n(Raw Datapath)", c_bg_0)
    draw_box(7.2, 6.8, "2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", c_bg_1, is_bold=True)
    draw_box(2.8, 4.5, "3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)", c_bg_2)
    draw_box(7.2, 4.5, "4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)", c_bg_3)
    draw_box(5.0, 2.2, "Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", c_bg_out)

    # 3. Draw Perfect Orthogonal Routing Lines
    arrow_props = dict(arrowstyle="-|>", mutation_scale=15, linewidth=1.5, zorder=3)
    
    def dline(x1, y1, x2, y2, color):
        ax.plot([x1, x2], [y1, y2], color=color, linewidth=1.5, zorder=2)
        
    def darrow(x1, y1, x2, y2, color):
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1), arrowprops=dict(color=color, **arrow_props))

    # --- AXI4 Input Routing ---
    dline(5.0, 9.1, 5.0, 8.6, c_arr_in)
    dline(0.5, 8.6, 9.5, 8.6, c_arr_in) # Top distribution bus
    
    darrow(2.8, 8.6, 2.8, 7.3, c_arr_in) # Drop to B0
    darrow(7.2, 8.6, 7.2, 7.3, c_arr_in) # Drop to B1
    
    dline(0.5, 8.6, 0.5, 5.5, c_arr_in)  # Outer left channel
    dline(0.5, 5.5, 2.8, 5.5, c_arr_in)  
    darrow(2.8, 5.5, 2.8, 5.0, c_arr_in) # Drop to B2

    dline(9.5, 8.6, 9.5, 5.5, c_arr_in)  # Outer right channel
    dline(9.5, 5.5, 7.2, 5.5, c_arr_in)  
    darrow(7.2, 5.5, 7.2, 5.0, c_arr_in) # Drop to B3

    # --- Output Routing ---
    dline(2.8, 6.3, 2.8, 5.75, c_arr_0)  # B0 drops slightly
    dline(2.8, 5.75, 4.9, 5.75, c_arr_0) # B0 routes to center channel
    dline(4.9, 5.75, 4.9, 3.2, c_arr_0)  # B0 drops to bottom bus

    dline(7.2, 6.3, 7.2, 5.75, c_arr_1)  # B1 drops slightly
    dline(7.2, 5.75, 5.1, 5.75, c_arr_1) # B1 routes to center channel
    dline(5.1, 5.75, 5.1, 3.2, c_arr_1)  # B1 drops to bottom bus

    dline(2.8, 4.0, 2.8, 3.2, c_arr_2)   # B2 drops directly to bottom bus
    dline(7.2, 4.0, 7.2, 3.2, c_arr_3)   # B3 drops directly to bottom bus

    dline(2.8, 3.2, 7.2, 3.2, c_arr_out) # Bottom merge bus
    darrow(5.0, 3.2, 5.0, 2.7, c_arr_out) # Final drop to Output Box

    # Save outputs
    prefix = "diagrams_color" if is_color else "diagrams_mono"
    plt.savefig(f"{prefix}/fig_all_branches_final.png", dpi=300, bbox_inches='tight')
    plt.savefig(f"{prefix}/fig_all_branches_final.pdf", bbox_inches='tight')
    plt.close()

draw_diagram(is_color=True)
draw_diagram(is_color=False)
print("SUCCESS: Perfect coordinate block diagrams generated in diagrams_color/ and diagrams_mono/")
