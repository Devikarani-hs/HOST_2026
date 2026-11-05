#!/bin/bash
mkdir -p diagrams_color diagrams_mono

echo "Generating Pareto Architecture Branches Diagram..."

# Color Version
cat << 'DOT' > diagrams_color/fig5_pareto_branches.dot
digraph G {
    rankdir=TB;
    node [shape=box, style="rounded,filled", fillcolor=white, fontname="Arial", fontsize=11];
    edge [fontname="Arial", fontsize=10];

    Title [label="Key Derivation Module (KDM)\nCountermeasure Exploration Space", shape=plaintext, fontname="Arial bold", fontsize=14, fillcolor=none];

    Baseline [label="Unprotected Baseline\n- No Countermeasures\n- 482 LUTs, 1148 Mbps", fillcolor="#ffcdd2", penwidth=2, color="#d62728"];

    subgraph cluster_branches {
        label="Investigated Countermeasure Branches (DMR Enabled)";
        style=dashed; color=gray;
        
        B1 [label="Branch 1: Masked+DMR\n(Proposed Pareto-Optimal)\n- 1st-Order Boolean Masking\n- Register Barriers\n- 1942 LUTs, 574 Mbps", fillcolor="#c8e6c9", penwidth=3, color="#2ca02c"];
        
        B2 [label="Branch 2: Hiding+DMR\n(Failed Evaluation)\n- Dual-Rail Logic\n- 1205 LUTs, 574 Mbps", fillcolor="#ffe0b2", penwidth=1, color="#ff7f0e"];
        
        B3 [label="Branch 3: Morphing+DMR\n(Failed Evaluation)\n- Temporal Randomization\n- 1110 LUTs, 574 Mbps", fillcolor="#e1bee7", penwidth=1, color="#9467bd"];
    }

    Title -> Baseline [style=invis];
    Baseline -> B1;
    Baseline -> B2;
    Baseline -> B3;
}
DOT

# Monochrome Version (IEEE Print Standard)
cat << 'DOT' > diagrams_mono/fig5_pareto_branches.dot
digraph G {
    rankdir=TB;
    node [shape=box, style="rounded", fontname="Arial", fontsize=11];
    edge [fontname="Arial", fontsize=10];

    Title [label="Key Derivation Module (KDM)\nCountermeasure Exploration Space", shape=plaintext, fontname="Arial bold", fontsize=14];

    Baseline [label="Unprotected Baseline\n- No Countermeasures\n- 482 LUTs, 1148 Mbps", penwidth=2];

    subgraph cluster_branches {
        label="Investigated Countermeasure Branches (DMR Enabled)";
        style=dashed; color=black;
        
        B1 [label="Branch 1: Masked+DMR\n(Proposed Pareto-Optimal)\n- 1st-Order Boolean Masking\n- Register Barriers\n- 1942 LUTs, 574 Mbps", penwidth=3];
        
        B2 [label="Branch 2: Hiding+DMR\n(Failed Evaluation)\n- Dual-Rail Logic\n- 1205 LUTs, 574 Mbps", style=dotted, penwidth=2];
        
        B3 [label="Branch 3: Morphing+DMR\n(Failed Evaluation)\n- Temporal Randomization\n- 1110 LUTs, 574 Mbps", style=dotted, penwidth=2];
    }

    Title -> Baseline [style=invis];
    Baseline -> B1;
    Baseline -> B2;
    Baseline -> B3;
}
DOT

echo "Compiling Pareto Branches diagram to PNG and PDF..."
dot -Tpng -Gdpi=300 diagrams_color/fig5_pareto_branches.dot -o diagrams_color/fig5_pareto_branches.png
dot -Tpdf diagrams_color/fig5_pareto_branches.dot -o diagrams_color/fig5_pareto_branches.pdf

dot -Tpng -Gdpi=300 diagrams_mono/fig5_pareto_branches.dot -o diagrams_mono/fig5_pareto_branches.png
dot -Tpdf diagrams_mono/fig5_pareto_branches.dot -o diagrams_mono/fig5_pareto_branches.pdf

echo "SUCCESS! Figure 5 generated in diagrams_color/ and diagrams_mono/."
