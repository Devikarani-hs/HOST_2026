#!/bin/bash
mkdir -p diagrams_color diagrams_mono

# To completely fix the Graphviz routing and alignment issues with external nodes (like the Input and Output),
# we will use an invisible structural grid to force perfect symmetry.

cat << 'DOT' > diagrams_mono/fig_all_branches.dot
digraph G {
    rankdir=TD;
    splines=ortho;
    nodesep=0.5;
    ranksep=0.5;
    
    node [shape=box, style="rounded", fontname="Arial", fontsize=11, width=3.8, height=0.7];
    edge [fontname="Arial", fontsize=10];
    
    # 1. Top Level (Input)
    { rank=same; 
      in_L [shape=point, style=invis]; 
      Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold"];
      in_R [shape=point, style=invis]; 
    }
    
    # 2. Split Level
    { rank=same;
      split_L [shape=point, width=0];
      split_C [shape=point, style=invis];
      split_R [shape=point, width=0];
    }
    
    # 3. First Row of Branches
    { rank=same;
      B0 [label="1. Unprotected Baseline\n(Raw Datapath)"];
      mid1 [shape=point, style=invis];
      B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", style="rounded,bold", penwidth=2];
    }
    
    # 4. Second Row of Branches
    { rank=same;
      B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)"];
      mid2 [shape=point, style=invis];
      B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)"];
    }
    
    # 5. Merge Level
    { rank=same;
      merge_L [shape=point, width=0];
      merge_C [shape=point, style=invis];
      merge_R [shape=point, width=0];
    }
    
    # 6. Bottom Level (Output)
    { rank=same;
      out_L [shape=point, style=invis];
      Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=box, style="filled,solid", fillcolor="#f0f0f0"];
      out_R [shape=point, style=invis];
    }

    # Structural Alignment (Invisible)
    in_L -> split_L -> B0 -> B2 -> merge_L -> out_L [style=invis, weight=100];
    Input -> split_C -> mid1 -> mid2 -> merge_C -> Output [style=invis, weight=100];
    in_R -> split_R -> B1 -> B3 -> merge_R -> out_R [style=invis, weight=100];
    
    # Cluster for the design space
    subgraph cluster_options {
        label="Design Space Exploration\n(Evaluated Countermeasure Branches)";
        style=dashed; color=black; fontname="Arial bold"; margin=20;
        B0; B1; B2; B3; mid1; mid2;
    }

    # Visible Data Routing
    Input -> split_C [dir=none];
    split_C -> split_L [dir=none];
    split_C -> split_R [dir=none];
    
    split_L -> B0;
    split_L -> B2;
    split_R -> B1;
    split_R -> B3;
    
    B0 -> merge_L [dir=none];
    B2 -> merge_L [dir=none];
    B1 -> merge_R [dir=none];
    B3 -> merge_R [dir=none];
    
    merge_L -> merge_C [dir=none];
    merge_R -> merge_C [dir=none];
    merge_C -> Output;
}
DOT

cat << 'DOT' > diagrams_color/fig_all_branches.dot
digraph G {
    rankdir=TD;
    splines=ortho;
    nodesep=0.5;
    ranksep=0.5;
    
    node [shape=box, style="rounded,filled", fontname="Arial", fontsize=11, width=3.8, height=0.7];
    edge [fontname="Arial", fontsize=10];
    
    # 1. Top Level (Input)
    { rank=same; 
      in_L [shape=point, style=invis]; 
      Input [label="AXI4-Stream Input Data (v)", shape=plaintext, fontname="Arial bold", fillcolor=none];
      in_R [shape=point, style=invis]; 
    }
    
    # 2. Split Level
    { rank=same;
      split_L [shape=point, width=0];
      split_C [shape=point, style=invis];
      split_R [shape=point, width=0];
    }
    
    # 3. First Row of Branches
    { rank=same;
      B0 [label="1. Unprotected Baseline\n(Raw Datapath)", fillcolor="#ffcdd2"];
      mid1 [shape=point, style=invis];
      B1 [label="2. Branch 1: Masked + DMR\n(1st-Order Boolean Masking + Redundancy)", fillcolor="#c8e6c9", penwidth=2];
    }
    
    # 4. Second Row of Branches
    { rank=same;
      B2 [label="3. Branch 2: Hiding + DMR\n(Dual-Rail Capacitive Balancing + Redundancy)", fillcolor="#ffe0b2"];
      mid2 [shape=point, style=invis];
      B3 [label="4. Branch 3: Morphing + DMR\n(Temporal Delay Insertion + Redundancy)", fillcolor="#e1bee7"];
    }
    
    # 5. Merge Level
    { rank=same;
      merge_L [shape=point, width=0];
      merge_C [shape=point, style=invis];
      merge_R [shape=point, width=0];
    }
    
    # 6. Bottom Level (Output)
    { rank=same;
      out_L [shape=point, style=invis];
      Output [label="Evaluated PPA & TVLA Metrics\n(|t|-values, LUTs, Throughput)", shape=box, fillcolor="#e3f2fd"];
      out_R [shape=point, style=invis];
    }

    # Structural Alignment (Invisible)
    in_L -> split_L -> B0 -> B2 -> merge_L -> out_L [style=invis, weight=100];
    Input -> split_C -> mid1 -> mid2 -> merge_C -> Output [style=invis, weight=100];
    in_R -> split_R -> B1 -> B3 -> merge_R -> out_R [style=invis, weight=100];
    
    # Cluster for the design space
    subgraph cluster_options {
        label="Design Space Exploration\n(Evaluated Countermeasure Branches)";
        style=dashed; color=gray; fontname="Arial bold"; margin=20; fillcolor=none;
        B0; B1; B2; B3; mid1; mid2;
    }

    # Visible Data Routing
    Input -> split_C [dir=none, color=gray, penwidth=1.5];
    split_C -> split_L [dir=none, color=gray, penwidth=1.5];
    split_C -> split_R [dir=none, color=gray, penwidth=1.5];
    
    split_L -> B0 [color=gray, penwidth=1.5];
    split_L -> B2 [color=gray, penwidth=1.5];
    split_R -> B1 [color=gray, penwidth=1.5];
    split_R -> B3 [color=gray, penwidth=1.5];
    
    B0 -> merge_L [dir=none, color="#d32f2f", penwidth=1.5];
    B2 -> merge_L [dir=none, color="#f57c00", penwidth=1.5];
    B1 -> merge_R [dir=none, color="#388e3c", penwidth=2.0];
    B3 -> merge_R [dir=none, color="#7b1fa2", penwidth=1.5];
    
    merge_L -> merge_C [dir=none, color=gray, penwidth=1.5];
    merge_R -> merge_C [dir=none, color=gray, penwidth=1.5];
    merge_C -> Output [color=gray, penwidth=1.5];
}
DOT

dot -Tpng -Gdpi=300 diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.png
dot -Tpdf diagrams_mono/fig_all_branches.dot -o diagrams_mono/fig_all_branches.pdf

dot -Tpng -Gdpi=300 diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.png
dot -Tpdf diagrams_color/fig_all_branches.dot -o diagrams_color/fig_all_branches.pdf

echo "[SUCCESS] Perfect symmetry achieved. Generated diagrams in diagrams_mono/ and diagrams_color/"
