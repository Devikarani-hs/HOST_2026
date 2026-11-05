#!/bin/bash
mkdir -p diagrams

echo "Generating Detailed FPGA Routing Failure Concept..."
cat << 'DOT' > diagrams/fig4_routing_failure_detailed.dot
digraph G {
    rankdir=TB; compound=true;
    node [shape=box, fontname="Arial", fontsize=11, style="rounded,filled", fillcolor=white];
    edge [fontname="Arial", fontsize=10];
    
    subgraph cluster_ASIC {
        label="Theory / ASIC Layout\n(Perfect Symmetry)"; style=dashed; fillcolor="#f1f8e9"; style=filled; fontname="Arial bold";
        
        A_Src1 [label="Source\n(Rail 1)"];
        A_Src2 [label="Source\n(Rail 2)"];
        
        A_Dest1 [label="Destination\nGate 1"];
        A_Dest2 [label="Destination\nGate 2"];
        
        A_Src1 -> A_Dest1 [label=" Length = X\nCapacitance = C", color="#2e7d32", penwidth=2.5];
        A_Src2 -> A_Dest2 [label=" Length = X\nCapacitance = C", color="#2e7d32", penwidth=2.5];
        
        Result1 [label="Balanced Power Trace\n(Hiding Succeeds)", shape=plaintext, fillcolor=transparent, fontname="Arial bold"];
        A_Dest1 -> Result1 [style=invis];
    }

    subgraph cluster_FPGA {
        label="FPGA Reality\n(Automated Switch Matrix Routing)"; style=dashed; fillcolor="#ffebee"; style=filled; fontname="Arial bold";
        
        F_Src1 [label="Source LUT\n(Rail 1)"];
        F_Src2 [label="Source LUT\n(Rail 2)"];
        
        subgraph cluster_Fabric {
            label="Rigid FPGA Routing Fabric"; style=dotted; fillcolor=white; style=filled; fontname="Arial italic";
            SM1 [label="Switch\nMatrix A", shape=diamond, fillcolor="#e0e0e0"];
            SM2 [label="Switch\nMatrix B", shape=diamond, fillcolor="#e0e0e0"];
            SM3 [label="Switch\nMatrix C", shape=diamond, fillcolor="#e0e0e0"];
            
            SM1 -> SM2 [style=invis];
        }
        
        F_Dest1 [label="Destination LUT\n(Rail 1)"];
        F_Dest2 [label="Destination LUT\n(Rail 2)"];
        
        // The skewed path (Rail 1 takes a long route)
        F_Src1 -> SM1 [color="#d32f2f", penwidth=2];
        SM1 -> SM2 [color="#d32f2f", penwidth=2];
        SM2 -> SM3 [color="#d32f2f", penwidth=2];
        SM3 -> F_Dest1 [label=" Length = X+Δ\nCap = C1", color="#d32f2f", style=dashed, penwidth=2];
        
        // The direct path (Rail 2 takes a short route)
        F_Src2 -> SM1 [color="#1976d2", penwidth=2];
        SM1 -> F_Dest2 [label=" Length = Y\nCap = C2", color="#1976d2", penwidth=2];
        
        Result2 [label="Transient Glitch Leakage\n(|t| = 56.98, Hiding Fails)", shape=plaintext, fillcolor=transparent, fontcolor="#d32f2f", fontname="Arial bold"];
        F_Dest1 -> Result2 [style=invis];
    }
}
DOT
dot -Tpng -Gdpi=300 diagrams/fig4_routing_failure_detailed.dot -o diagrams/fig4_routing_failure_detailed.png
dot -Tpdf diagrams/fig4_routing_failure_detailed.dot -o diagrams/fig4_routing_failure_detailed.pdf

echo "SUCCESS! Detailed Fig 4 generated as fig4_routing_failure_detailed.png/pdf"
