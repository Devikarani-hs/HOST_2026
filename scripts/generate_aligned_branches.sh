#!/bin/bash
mkdir -p diagrams_color diagrams_mono

# ==========================================
# 1. Monochrome Version (Strict IEEE format)
# ==========================================
cat << 'DOT' > diagrams_mono/fig_all_branches.dot
digraph G {
    rankdir=TB;
    nodesep=0.5;
    ranksep=0.6;
    node [shape=box, style="rounded", fontname="Arial", fontsize=11, width=3.5];
    
    Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold"];
    
    subgraph cluster_options {
        label="Design Space Exploration\n(Evaluated Countermeasure Branches)";
        style=dashed; color=black; fontname="Arial bold"; margin=20;
        
        {rank=same; B0; B1;}
        {rank=same; B2; B3;}
        
        B0 [label="1. Unprotected Baseline\n(Raw Datapath)"];
        B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", style="rounded,bold"];
        B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)"];
        B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)"];
        
        # Invisible edges to force square layout
        B0 -> B2 [style=invis];
        B1 -> B3 [style=invis];
    }
    
    Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=ellipse, style="filled,solid", fillcolor="#f0f0f0"];

    Input -> B0;
    Input -> B1;
    Input -> B2;
    Input -> B3;
    
    B0 -> Output;
    B1 -> Output;
    B2 -> Output;
    B3 -> Output;
}
DOT

# ==========================================
# 2. Color Version (Presentation Format)
# ==========================================
cat << 'DOT' > diagrams_color/fig_all_branches.dot
digraph G {
    rankdir=TB;
    nodesep=0.5;
    ranksep=0.6;
    node [shape=box, style="rounded,filled", fontname="Arial", fontsize=11, width=3.5];
    
    Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold", fillcolor=none];
    
    subgraph cluster_options {
        label="Design Space Exploration\n(Evaluated Countermeasure Branches)";
        style=dashed; color=gray; fontname="Arial bold"; margin=20;
        
        {rank=same; B0; B1;}
        {rank=same; B2; B3;}
        
        B0 [label="1. Unprotected Baseline\n(Raw Datapath)", fillcolor="#ffcdd2"];
        B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", fillcolor="#c8e6c9", penwidth=2];
        B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)", fillcolor="#ffe0b2"];
        B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)", fillcolor="#e1bee7"];
        
        # Invisible edges to force square layout
        B0 -> B2 [style=invis];
        B1 -> B3 [style=invis];
    }
    
    Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=ellipse, fillcolor="#e3f2fd"];

    Input -> B0 [color=gray, penwidth=1.5];
    Input -> B1 [color=gray, penwidth=1.5];
    Input -> B2 [color=gray, penwidth=1.5];
    Input -> B3 [color=gray, penwidth=1.5];
    
    B0 -> Output [color="#d32f2f", penwidth=1.5];
    B1 -> Output [color="#388e3c", penwidth=2.0];
    B2 -> Output [color="#f57c00", penwidth=1.5];
    B3 -> Output [color="#7b1fa2", penwidth=1.5];
}
DOT

dot -Tpng -Gdpi=300 diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.png
dot -Tpdf diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.pdf

dot -Tpng -Gdpi=300 diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.png
dot -Tpdf diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.pdf

echo "[SUCCESS] Aligned monochrome and color architecture diagrams generated."
