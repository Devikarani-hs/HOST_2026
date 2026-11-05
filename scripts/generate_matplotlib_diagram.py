import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

os.makedirs('diagrams_color', exist_ok=True)
os.makedirs('diagrams_mono', exist_ok=True)

def draw_diagram(is_color=True):
    fig, ax = plt.subplots(figsize=(10, 6.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Define colors
    if is_color:
        c_bg_0 = '#ffcdd2' # Red (Baseline)
        c_bg_1 = '#c8e6c9' # Green (Masked)
        c_bg_2 = '#ffe0b2' # Orange (Hiding)
        c_bg_3 = '#e1bee7' # Purple (Morphing)
        c_bg_out = '#e3f2fd' # Blue
        c_edge = 'black'
        
        c_arr_in = 'gray'
        c_arr_0 = '#d32f2f'
        c_arr_1 = '#388e3c'
        c_arr_2 = '#f57c00'
        c_arr_3 = '#7b1fa2'
    else:
        c_bg_0 = c_bg_1 = c_bg_2 = c_bg_3 = c_bg_out = 'white'
        c_edge = 'black'
        c_arr_in = c_arr_0 = c_arr_1 = c_arr_2 = c_arr_3 = 'black'

    # Box dimensions
    box_w = 4.2
    box_h = 1.1
    
    # Box coordinates (center x, center y)
    x_left = 2.7
    x_right = 7.3
    y_top = 6.8
    y_bot = 4.5
    
    # 1. Draw Cluster Box (Dashed)
    rect_cluster = patches.Rectangle((0.4, 3.5), 9.2, 5.2, linewidth=1.5, edgecolor='gray' if is_color else 'black', facecolor='none', linestyle='--')
    ax.add_patch(rect_cluster)
    ax.text(5.0, 8.2, "Design Space Exploration\n(Evaluated Countermeasure Branches)", 
            ha='center', va='center', fontsize=12, fontweight='bold', family='sans-serif')

    # Function to draw a rounded box with text
    def draw_box(x, y, text, bg_color, is_bold=False):
        lw = 2.5 if is_bold else 1.0
        rect = patches.FancyBboxPatch((x - box_w/2, y - box_h/2), box_w, box_h, 
                                      boxstyle="round,pad=0.1,rounding_size=0.15", 
                                      linewidth=lw, edgecolor=c_edge, facecolor=bg_color)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center', fontsize=10, family='sans-serif', 
                fontweight='bold' if is_bold else 'normal')

    # Draw the 4 branch boxes
    draw_box(x_left, y_top, "1. Unprotected Baseline\n(Raw Datapath)", c_bg_0)
    draw_box(x_right, y_top, "2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", c_bg_1, is_bold=True)
    draw_box(x_left, y_bot, "3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)", c_bg_2)
    draw_box(x_right, y_bot, "4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)", c_bg_3)

    # Input and Output Nodes
    ax.text(5.0, 9.4, "AXI4-Stream Input Data (v)", ha='center', va='center', fontsize=12, fontweight='bold', family='sans-serif')
    draw_box(5.0, 1.5, "Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", c_bg_out)

    # --- Draw Arrows ---
    arrow_props = dict(arrowstyle="-|>", mutation_scale=15, linewidth=1.5)
    line_props = dict(linewidth=1.5)

    def draw_line(x1, y1, x2, y2, color):
        ax.plot([x1, x2], [y1, y2], color=color, **line_props)
    
    def draw_arrow(x1, y1, x2, y2, color):
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1), arrowprops=dict(color=color, **arrow_props))

    # --- INPUT ROUTING (Top Down) ---
    draw_line(5.0, 9.1, 5.0, 8.8, c_arr_in) # Main drop from text
    draw_line(1.5, 8.8, 8.5, 8.8, c_arr_in) # Main horizontal split
    
    # Drops to Top Row
    draw_arrow(2.7, 8.8, 2.7, y_top + box_h/2 + 0.1, c_arr_in) # To Baseline
    draw_arrow(7.3, 8.8, 7.3, y_top + box_h/2 + 0.1, c_arr_in) # To Masked
    
    # Drops to Bottom Row (Routing cleanly AROUND the outside of the top boxes)
    draw_line(1.5, 8.8, 1.5, y_bot + box_h/2 + 0.4, c_arr_in) # Left outer drop
    draw_line(1.5, y_bot + box_h/2 + 0.4, 2.7, y_bot + box_h/2 + 0.4, c_arr_in) # Route inward
    draw_arrow(2.7, y_bot + box_h/2 + 0.4, 2.7, y_bot + box_h/2 + 0.1, c_arr_in) # To Hiding

    draw_line(8.5, 8.8, 8.5, y_bot + box_h/2 + 0.4, c_arr_in) # Right outer drop
    draw_line(8.5, y_bot + box_h/2 + 0.4, 7.3, y_bot + box_h/2 + 0.4, c_arr_in) # Route inward
    draw_arrow(7.3, y_bot + box_h/2 + 0.4, 7.3, y_bot + box_h/2 + 0.1, c_arr_in) # To Morphing

    # --- OUTPUT ROUTING (Bottom Merge) ---
    # Drops from Top Row (Routing down the center channel)
    draw_line(x_left + 1.0, y_top - box_h/2 - 0.1, x_left + 1.0, 2.8, c_arr_0)
    draw_line(x_right - 1.0, y_top - box_h/2 - 0.1, x_right - 1.0, 2.8, c_arr_1)
    
    # Drops from Bottom Row (Center channel)
    draw_line(x_left + 1.0, y_bot - box_h/2 - 0.1, x_left + 1.0, 2.8, c_arr_2)
    draw_line(x_right - 1.0, y_bot - box_h/2 - 0.1, x_right - 1.0, 2.8, c_arr_3)
    
    # Horizontal merge at the bottom
    draw_line(x_left + 1.0, 2.8, x_right - 1.0, 2.8, c_arr_in) 
    
    # Final drop to output box
    draw_arrow(5.0, 2.8, 5.0, 1.5 + box_h/2 + 0.1, c_arr_in)

    plt.tight_layout()
    
    prefix = "diagrams_color" if is_color else "diagrams_mono"
    plt.savefig(f"{prefix}/fig_all_branches_perfect.png", dpi=300, bbox_inches='tight')
    plt.savefig(f"{prefix}/fig_all_branches_perfect.pdf", bbox_inches='tight')
    plt.close()

draw_diagram(is_color=True)
draw_diagram(is_color=False)
print("[SUCCESS] Mathematically perfect coordinate diagrams generated in diagrams_color/ and diagrams_mono/")
