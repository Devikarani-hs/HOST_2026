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
    
    Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold"];
    
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
    }
    
    Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=box, style="filled,solid", fillcolor="#f0f0f0"];

    # Use an intermediate point for clean orthogonal routing from input
    Input_Split [shape=point, width=0];
    Input -> Input_Split [dir=none];
    Input_Split -> B0;
    Input_Split -> B1;
    Input_Split -> B2;
    Input_Split -> B3;
    
    # Use an intermediate point for clean orthogonal routing to output
    Output_Merge [shape=point, width=0];
    B0 -> Output_Merge [dir=none];
    B1 -> Output_Merge [dir=none];
    B2 -> Output_Merge [dir=none];
    B3 -> Output_Merge [dir=none];
    Output_Merge -> Output;
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
    }
    
    Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=box, fillcolor="#e3f2fd"];

    # Use an intermediate point for clean orthogonal routing from input
    Input_Split [shape=point, width=0];
    Input -> Input_Split [dir=none, color=gray, penwidth=1.5];
    Input_Split -> B0 [color=gray, penwidth=1.5];
    Input_Split -> B1 [color=gray, penwidth=1.5];
    Input_Split -> B2 [color=gray, penwidth=1.5];
    Input_Split -> B3 [color=gray, penwidth=1.5];
    
    # Use an intermediate point for clean orthogonal routing to output
    Output_Merge [shape=point, width=0];
    B0 -> Output_Merge [dir=none, color="#d32f2f", penwidth=1.5];
    B1 -> Output_Merge [dir=none, color="#388e3c", penwidth=2.0];
    B2 -> Output_Merge [dir=none, color="#f57c00", penwidth=1.5];
    B3 -> Output_Merge [dir=none, color="#7b1fa2", penwidth=1.5];
    Output_Merge -> Output [color=gray, penwidth=1.5];
}
DOT

dot -Tpng -Gdpi=300 diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.png
dot -Tpdf diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.pdf

dot -Tpng -Gdpi=300 diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.png
dot -Tpdf diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.pdf

echo "[SUCCESS] Neat orthogonal architecture diagrams generated."
