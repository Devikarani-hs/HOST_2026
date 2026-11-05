#!/bin/bash
mkdir -p diagrams_color diagrams_mono

# ==========================================
# 1. Monochrome Version (Strict IEEE format)
# ==========================================
cat << 'DOT' > diagrams_mono/fig_all_branches.dot
digraph G {
    rankdir=TD;
    splines=ortho;
    nodesep=0.8;
    ranksep=0.8;
    
    node [shape=box, style="rounded", fontname="Arial", fontsize=11, width=4.0, height=0.7];
    edge [fontname="Arial", fontsize=10];
    
    # Create invisible alignment nodes to force centering
    Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold"];
    In_Center [shape=point, width=0, style=invis];
    
    subgraph cluster_options {
        label="Design Space Exploration\n(Evaluated Countermeasure Branches)";
        style=dashed; color=black; fontname="Arial bold"; margin=25;
        
        {rank=same; B0; B1;}
        {rank=same; B2; B3;}
        
        B0 [label="1. Unprotected Baseline\n(Raw Datapath)"];
        B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", style="rounded,bold", penwidth=2];
        B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)"];
        B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)"];
        
        # Invis edges to enforce layout
        B0 -> B2 [style=invis];
        B1 -> B3 [style=invis];
        
        # Center alignment inside cluster
        Center [shape=point, width=0, style=invis];
        {rank=same; B0; Center; B1;}
        B0 -> Center -> B1 [style=invis];
    }
    
    Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=box, style="filled,solid", fillcolor="#f0f0f0"];

    # Routing from Input
    Input -> In_Center [dir=none];
    In_Center -> B0;
    In_Center -> B1;
    In_Center -> B2;
    In_Center -> B3;
    
    # Routing to Output
    Out_Center [shape=point, width=0, style=invis];
    B0 -> Out_Center [dir=none];
    B1 -> Out_Center [dir=none];
    B2 -> Out_Center [dir=none];
    B3 -> Out_Center [dir=none];
    Out_Center -> Output;
    
    # Force structural vertical alignment (This fixes the hanging nodes)
    Input -> In_Center -> Center -> Out_Center -> Output [style=invis, weight=100];
}
DOT

# ==========================================
# 2. Color Version (Presentation Format)
# ==========================================
cat << 'DOT' > diagrams_color/fig_all_branches.dot
digraph G {
    rankdir=TD;
    splines=ortho;
    nodesep=0.8;
    ranksep=0.8;
    
    node [shape=box, style="rounded,filled", fontname="Arial", fontsize=11, width=4.0, height=0.7];
    edge [fontname="Arial", fontsize=10];
    
    Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold", fillcolor=none];
    In_Center [shape=point, width=0, style=invis];
    
    subgraph cluster_options {
        label="Design Space Exploration\n(Evaluated Countermeasure Branches)";
        style=dashed; color=gray; fontname="Arial bold"; margin=25; fillcolor=none;
        
        {rank=same; B0; B1;}
        {rank=same; B2; B3;}
        
        B0 [label="1. Unprotected Baseline\n(Raw Datapath)", fillcolor="#ffcdd2"];
        B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", fillcolor="#c8e6c9", penwidth=2];
        B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)", fillcolor="#ffe0b2"];
        B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)", fillcolor="#e1bee7"];
        
        # Invis edges to enforce layout
        B0 -> B2 [style=invis];
        B1 -> B3 [style=invis];
        
        # Center alignment inside cluster
        Center [shape=point, width=0, style=invis];
        {rank=same; B0; Center; B1;}
        B0 -> Center -> B1 [style=invis];
    }
    
    Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=box, fillcolor="#e3f2fd"];

    # Routing from Input
    Input -> In_Center [dir=none, color=gray, penwidth=1.5];
    In_Center -> B0 [color=gray, penwidth=1.5];
    In_Center -> B1 [color=gray, penwidth=1.5];
    In_Center -> B2 [color=gray, penwidth=1.5];
    In_Center -> B3 [color=gray, penwidth=1.5];
    
    # Routing to Output
    Out_Center [shape=point, width=0, style=invis];
    B0 -> Out_Center [dir=none, color="#d32f2f", penwidth=1.5];
    B1 -> Out_Center [dir=none, color="#388e3c", penwidth=2.0];
    B2 -> Out_Center [dir=none, color="#f57c00", penwidth=1.5];
    B3 -> Out_Center [dir=none, color="#7b1fa2", penwidth=1.5];
    Out_Center -> Output [color=gray, penwidth=1.5];
    
    # Force structural vertical alignment (This fixes the hanging nodes)
    Input -> In_Center -> Center -> Out_Center -> Output [style=invis, weight=100];
}
DOT

dot -Tpng -Gdpi=300 diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.png
dot -Tpdf diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.pdf

dot -Tpng -Gdpi=300 diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.png
dot -Tpdf diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.pdf

echo "[SUCCESS] Perfectly centered orthogonal architecture diagrams generated."
