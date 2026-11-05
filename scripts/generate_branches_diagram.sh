#!/bin/bash
mkdir -p diagrams_mono diagrams_color

# Monochrome Version (Best for strict IEEE print formatting)
cat << 'DOT' > diagrams_mono/fig_all_branches.dot
digraph G {
    rankdir=TB;
    node [shape=box, style="rounded", fontname="Arial", fontsize=11];
    
    Input [label="AXI4-Stream Input Data (v)", shape=plaintext];
    
    subgraph cluster_options {
        label="Design Space Exploration (Evaluated Countermeasure Branches)";
        style=dashed; color=black; fontname="Arial bold";
        
        B0 [label="1. Unprotected Baseline\n(Raw Datapath)", width=2.2];
        B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", width=2.2, style="rounded,bold"];
        B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)", width=2.2];
        B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)", width=2.2];
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

dot -Tpng -Gdpi=300 diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.png
dot -Tpdf diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.pdf

echo "[SUCCESS] All-branches architecture diagram generated in diagrams_mono/"
