#!/bin/bash
mkdir -p diagrams

echo "[1/4] Generating High-Level Threat Model..."
cat << 'DOT' > diagrams/fig1_threat_model.dot
digraph G {
    rankdir=LR;
    node [shape=box, style="rounded,filled", fillcolor=white, fontname="Arial", fontsize=12];
    edge [fontname="Arial", fontsize=10];

    subgraph cluster_fpga {
        label = "Kintex UltraScale+ FPGA (xcku5p)";
        style=dashed; color=gray; fontname="Arial bold";
        
        KDM [label="Key Derivation Module\n(Proposed Masked+DMR)", fillcolor="#e1f5fe", penwidth=2];
        AES [label="100Gbps AES-GCM\nEncryption Engine", fillcolor="#f5f5f5"];
        
        KDM -> AES [label=" AXI4-Stream\n (key_valid, derived_key)", penwidth=1.5];
    }

    Network [label="High-Speed\nNetwork Data", shape=cylinder, fillcolor="#f1f8e9"];
    Network -> AES [label=" s_axis_tdata"];

    Attacker [label="Adversary", shape=octagon, style=filled, fillcolor="#ffebee", fontcolor=red, penwidth=2];
    
    Attacker -> KDM [label=" Side-Channel Analysis\n(Power/EM)", color=red, style=dashed];
    Attacker -> KDM [label=" Fault Injection\n(Laser/Clock Glitch)", color=red, style=dashed];
}
DOT
dot -Tpng -Gdpi=300 diagrams/fig1_threat_model.dot -o diagrams/fig1_threat_model.png
dot -Tpdf diagrams/fig1_threat_model.dot -o diagrams/fig1_threat_model.pdf

echo "[2/4] Generating Masked+DMR Architecture..."
cat << 'DOT' > diagrams/fig2_masked_dmr.dot
digraph G {
    rankdir=LR; splines=polyline;
    node [shape=box, style="rounded,filled", fillcolor=white, fontname="Arial"];
    
    Input [label="AXI In", shape=plaintext];
    
    subgraph cluster_dmrA {
        label="DMR Branch A"; style=dashed; color=blue;
        SplitA [label="Masking Split\n(v ⊕ m, m)"];
        BRAM_A [label="Hardened BRAM\n(LUT reduction)", shape=cylinder, fillcolor="#fff3e0"];
        RegA [label="Glitch-Mitigation\nRegister Barrier", fillcolor="#e8f5e9", penwidth=2];
        SplitA -> BRAM_A -> RegA;
    }

    subgraph cluster_dmrB {
        label="DMR Branch B (Redundant)"; style=dashed; color=blue;
        SplitB [label="Masking Split\n(v ⊕ m, m)"];
        BRAM_B [label="Hardened BRAM\n(LUT reduction)", shape=cylinder, fillcolor="#fff3e0"];
        RegB [label="Glitch-Mitigation\nRegister Barrier", fillcolor="#e8f5e9", penwidth=2];
        SplitB -> BRAM_B -> RegB;
    }

    Input -> SplitA; Input -> SplitB;

    Comp [label="Cycle-Accurate\nHardware Comparator", shape=diamond, fillcolor="#ffebee"];
    Output [label="Derived Key", shape=plaintext];
    Alarm [label="fi_alarm\n(FI Detected!)", shape=plaintext, fontcolor=red];

    RegA -> Output;
    RegA -> Comp;
    RegB -> Comp;
    Comp -> Alarm [color=red, penwidth=2];
}
DOT
dot -Tpng -Gdpi=300 diagrams/fig2_masked_dmr.dot -o diagrams/fig2_masked_dmr.png
dot -Tpdf diagrams/fig2_masked_dmr.dot -o diagrams/fig2_masked_dmr.pdf

echo "[3/4] Generating Pre-Silicon TVLA Methodology..."
cat << 'DOT' > diagrams/fig3_methodology.dot
digraph G {
    rankdir=TD;
    node [shape=box, style="filled", fillcolor="#f3e5f5", fontname="Arial"];
    edge [penwidth=1.5];

    RTL [label="Verilog RTL Modules\n(Unprotected, Masked, Hiding, Morphing)"];
    Synth [label="Vivado Automated PnR\n(Kintex UltraScale+)", fillcolor="#e3f2fd"];
    Sim [label="XSim Gate-Level Simulation\n(100,000 Fixed/Random Traces)", fillcolor="#e8f5e9"];
    VCD [label="Massive VCD Dump\n+ SDF Back-Annotation", shape=cylinder, fillcolor="#fff9c4"];
    Parser [label="Python Hamming Distance Extractor\n(Cycle-by-cycle physical wire toggles)", fillcolor="#ffe0b2"];
    Result [label="Welch's T-Test Evaluation\n(Max |t|-value)", shape=Mrecord, fillcolor="#ffcdd2", penwidth=2];

    RTL -> Synth;
    Synth -> Sim [label=" Gate-Level Netlist\n& Routing Delays"];
    Sim -> VCD;
    VCD -> Parser;
    Parser -> Result;
}
DOT
dot -Tpng -Gdpi=300 diagrams/fig3_methodology.dot -o diagrams/fig3_methodology.png
dot -Tpdf diagrams/fig3_methodology.dot -o diagrams/fig3_methodology.pdf

echo "[4/4] Generating FPGA Routing Failure Concept..."
cat << 'DOT' > diagrams/fig4_routing_failure.dot
digraph G {
    rankdir=TB; compound=true;
    node [shape=box, fontname="Arial"];
    
    subgraph cluster_ASIC {
        label="Theory / ASIC Layout\n(Perfect Symmetry)"; style=dashed; fillcolor="#f1f8e9"; style=filled;
        Source1 -> Dest1 [label=" Length = X\nCapacitance = C", color=green, penwidth=2];
        Source2 -> Dest2 [label=" Length = X\nCapacitance = C", color=green, penwidth=2];
        Result1 [label="Balanced Power Trace\n(Hiding Succeeds)", shape=plaintext];
        Dest1 -> Result1 [style=invis];
    }

    subgraph cluster_FPGA {
        label="FPGA Reality\n(Automated Switch Matrix Routing)"; style=dashed; fillcolor="#ffebee"; style=filled;
        Matrix [label="Rigid FPGA\nRouting Fabric", shape=octagon, style=filled, fillcolor=white];
        F_Source1 -> Matrix [color=red, penwidth=2];
        F_Source2 -> Matrix [color=blue, penwidth=2];
        Matrix -> F_Dest1 [label=" Length = X+Δ\nCap = C1", color=red, style=dashed, penwidth=2];
        Matrix -> F_Dest2 [label=" Length = Y\nCap = C2", color=blue, penwidth=2];
        
        Result2 [label="Transient Glitch Leakage\n(|t| = 56.98, Hiding Fails)", shape=plaintext, fontcolor=red];
        F_Dest1 -> Result2 [style=invis];
    }
}
DOT
dot -Tpng -Gdpi=300 diagrams/fig4_routing_failure.dot -o diagrams/fig4_routing_failure.png
dot -Tpdf diagrams/fig4_routing_failure.dot -o diagrams/fig4_routing_failure.pdf

echo "================================================================"
echo "SUCCESS! High-Resolution Diagrams generated in 'diagrams/' folder."
echo "Use the .pdf files for LaTeX insertion for infinite resolution."
echo "================================================================"
