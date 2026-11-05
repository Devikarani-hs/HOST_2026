#!/bin/bash
mkdir -p diagrams_color diagrams_mono

# ==========================================
# 1. Threat Model (100Gbps removed)
# ==========================================
echo "Generating Threat Model..."

# Color Version
cat << 'DOT' > diagrams_color/fig1_threat_model.dot
digraph G {
    rankdir=LR;
    node [shape=box, style="rounded,filled", fillcolor=white, fontname="Arial", fontsize=12];
    edge [fontname="Arial", fontsize=10];

    subgraph cluster_fpga {
        label = "Kintex UltraScale+ FPGA (xcku5p)";
        style=dashed; color=gray; fontname="Arial bold";
        
        KDM [label="Key Derivation Module\n(Proposed Masked+DMR)", fillcolor="#e1f5fe", penwidth=2];
        AES [label="AES-GCM\nEncryption Engine", fillcolor="#f5f5f5"];
        
        KDM -> AES [label=" AXI4-Stream\n (key_valid, derived_key)", penwidth=1.5];
    }

    Network [label="High-Speed\nNetwork Data", shape=cylinder, fillcolor="#f1f8e9"];
    Network -> AES [label=" s_axis_tdata"];

    Attacker [label="Adversary", shape=octagon, style=filled, fillcolor="#ffebee", fontcolor=red, penwidth=2];
    
    Attacker -> KDM [label=" Side-Channel Analysis\n(Power/EM)", color=red, style=dashed];
    Attacker -> KDM [label=" Fault Injection\n(Laser/Clock Glitch)", color=red, style=dashed];
}
DOT

# Monochrome Version
cat << 'DOT' > diagrams_mono/fig1_threat_model.dot
digraph G {
    rankdir=LR;
    node [shape=box, style="rounded", fontname="Arial", fontsize=12];
    edge [fontname="Arial", fontsize=10];

    subgraph cluster_fpga {
        label = "Kintex UltraScale+ FPGA (xcku5p)";
        style=dashed; color=black; fontname="Arial bold";
        
        KDM [label="Key Derivation Module\n(Proposed Masked+DMR)", penwidth=2];
        AES [label="AES-GCM\nEncryption Engine"];
        
        KDM -> AES [label=" AXI4-Stream\n (key_valid, derived_key)", penwidth=1.5];
    }

    Network [label="High-Speed\nNetwork Data", shape=cylinder];
    Network -> AES [label=" s_axis_tdata"];

    Attacker [label="Adversary", shape=octagon, style=bold, penwidth=2];
    
    Attacker -> KDM [label=" Side-Channel Analysis\n(Power/EM)", style=dashed];
    Attacker -> KDM [label=" Fault Injection\n(Laser/Clock Glitch)", style=dashed];
}
DOT

# ==========================================
# 2. Masked+DMR Architecture
# ==========================================
echo "Generating Masked+DMR Architecture..."

# Color Version
cat << 'DOT' > diagrams_color/fig2_masked_dmr.dot
digraph G {
    rankdir=LR; splines=polyline;
    node [shape=box, style="rounded,filled", fillcolor=white, fontname="Arial"];
    
    Input [label="AXI In", shape=plaintext, fillcolor=none];
    
    subgraph cluster_dmrA {
        label="DMR Branch A"; style=dashed; color=blue;
        SplitA [label="Masking Split\n(v ⊕ m, m)"];
        BRAM_A [label="Hardened BRAM\n(LUT reduction)", shape=cylinder, fillcolor="#fff3e0"];
        RegA [label="Glitch-Mitigation\nRegister Barrier", fillcolor="#e8f5e9", penwidth=2];
        SplitA -> BRAM_A -> RegA;
    }

    subgraph cluster_dmrB {
        label="DMR Branch B\n(Redundant)"; style=dashed; color=blue;
        SplitB [label="Masking Split\n(v ⊕ m, m)"];
        BRAM_B [label="Hardened BRAM\n(LUT reduction)", shape=cylinder, fillcolor="#fff3e0"];
        RegB [label="Glitch-Mitigation\nRegister Barrier", fillcolor="#e8f5e9", penwidth=2];
        SplitB -> BRAM_B -> RegB;
    }

    Input -> SplitA; Input -> SplitB;

    Comp [label="Cycle-Accurate\nHardware Comparator", shape=diamond, fillcolor="#ffebee"];
    Output [label="Derived Key", shape=plaintext, fillcolor=none];
    Alarm [label="fi_alarm\n(FI Detected!)", shape=plaintext, fontcolor=red, fillcolor=none];

    RegA -> Output;
    RegA -> Comp;
    RegB -> Comp;
    Comp -> Alarm [color=red, penwidth=2];
}
DOT

# Monochrome Version
cat << 'DOT' > diagrams_mono/fig2_masked_dmr.dot
digraph G {
    rankdir=LR; splines=polyline;
    node [shape=box, style="rounded", fontname="Arial"];
    
    Input [label="AXI In", shape=plaintext];
    
    subgraph cluster_dmrA {
        label="DMR Branch A"; style=dashed; color=black;
        SplitA [label="Masking Split\n(v ⊕ m, m)"];
        BRAM_A [label="Hardened BRAM\n(LUT reduction)", shape=cylinder];
        RegA [label="Glitch-Mitigation\nRegister Barrier", penwidth=2];
        SplitA -> BRAM_A -> RegA;
    }

    subgraph cluster_dmrB {
        label="DMR Branch B\n(Redundant)"; style=dashed; color=black;
        SplitB [label="Masking Split\n(v ⊕ m, m)"];
        BRAM_B [label="Hardened BRAM\n(LUT reduction)", shape=cylinder];
        RegB [label="Glitch-Mitigation\nRegister Barrier", penwidth=2];
        SplitB -> BRAM_B -> RegB;
    }

    Input -> SplitA; Input -> SplitB;

    Comp [label="Cycle-Accurate\nHardware Comparator", shape=diamond, style=filled, fillcolor="#f0f0f0"];
    Output [label="Derived Key", shape=plaintext];
    Alarm [label="fi_alarm\n(FI Detected)", shape=plaintext];

    RegA -> Output;
    RegA -> Comp;
    RegB -> Comp;
    Comp -> Alarm [penwidth=2, style=bold];
}
DOT

# ==========================================
# 3. Pre-Silicon Methodology
# ==========================================
echo "Generating Pre-Silicon Methodology..."

# Color Version
cat << 'DOT' > diagrams_color/fig3_methodology.dot
digraph G {
    rankdir=TD;
    node [shape=box, style="rounded,filled", fillcolor="#f3e5f5", fontname="Arial"];
    edge [penwidth=1.5];

    RTL [label="Verilog RTL Modules\n(Unprotected, Masked, Hiding, Morphing)"];
    Synth [label="Vivado Automated PnR\n(Kintex UltraScale+)", fillcolor="#e3f2fd"];
    Sim [label="XSim Gate-Level Simulation\n(100,000 Fixed/Random Traces)", fillcolor="#e8f5e9"];
    VCD [label="Massive VCD Dump\n+ SDF Back-Annotation", shape=cylinder, fillcolor="#fff9c4"];
    Parser [label="Python Hamming Distance Extractor\n(Cycle-by-cycle physical wire toggles)", fillcolor="#ffe0b2"];
    Result [label="Welch's T-Test Evaluation\n(Max |t|-value)", penwidth=2, fillcolor="#ffcdd2", style="rounded,filled,bold"];

    RTL -> Synth;
    Synth -> Sim [label=" Gate-Level Netlist\n& Routing Delays"];
    Sim -> VCD;
    VCD -> Parser;
    Parser -> Result;
}
DOT

# Monochrome Version
cat << 'DOT' > diagrams_mono/fig3_methodology.dot
digraph G {
    rankdir=TD;
    node [shape=box, style="rounded", fontname="Arial"];
    edge [penwidth=1.5];

    RTL [label="Verilog RTL Modules\n(Unprotected, Masked, Hiding, Morphing)"];
    Synth [label="Vivado Automated PnR\n(Kintex UltraScale+)"];
    Sim [label="XSim Gate-Level Simulation\n(100,000 Fixed/Random Traces)"];
    VCD [label="Massive VCD Dump\n+ SDF Back-Annotation", shape=cylinder];
    Parser [label="Python Hamming Distance Extractor\n(Cycle-by-cycle physical wire toggles)"];
    Result [label="Welch's T-Test Evaluation\n(Max |t|-value)", penwidth=2, style="rounded,bold"];

    RTL -> Synth;
    Synth -> Sim [label=" Gate-Level Netlist\n& Routing Delays"];
    Sim -> VCD;
    VCD -> Parser;
    Parser -> Result;
}
DOT

# ==========================================
# 4. FPGA Routing Failure
# ==========================================
echo "Generating FPGA Routing Failure Concept..."

# Color Version
cat << 'DOT' > diagrams_color/fig4_routing_failure.dot
digraph G {
    rankdir=TB; compound=true;
    node [shape=box, style="filled", fillcolor=white, fontname="Arial"];
    
    subgraph cluster_ASIC {
        label="Theory / ASIC Layout\n(Perfect Symmetry)"; style=dashed; fillcolor="#f1f8e9";
        Source1 [label="Source 1"]; Source2 [label="Source 2"];
        Dest1 [label="Dest 1"]; Dest2 [label="Dest 2"];
        Source1 -> Dest1 [label=" Length = X\nCapacitance = C", color=green, penwidth=2];
        Source2 -> Dest2 [label=" Length = X\nCapacitance = C", color=green, penwidth=2];
        Result1 [label="Balanced Power Trace\n(Hiding Succeeds)", shape=plaintext, fillcolor=none];
        Dest1 -> Result1 [style=invis];
    }

    subgraph cluster_FPGA {
        label="FPGA Reality\n(Automated Switch Matrix Routing)"; style=dashed; fillcolor="#ffebee";
        
        F_Source1 [label="Source 1\n(LUT)"]; F_Source2 [label="Source 2\n(LUT)"];
        F_Dest1 [label="Dest 1\n(LUT)"]; F_Dest2 [label="Dest 2\n(LUT)"];
        
        subgraph cluster_Fabric {
            label="Rigid FPGA Routing Fabric"; style=dotted; fillcolor=white;
            SM1 [label="Switch\nMatrix 1", shape=Mdiamond];
            SM2 [label="Switch\nMatrix 2", shape=Mdiamond];
            SM3 [label="Switch\nMatrix 3", shape=Mdiamond];
            SM1 -> SM2 [style=dashed, color=gray];
            SM2 -> SM3 [style=dashed, color=gray];
        }

        F_Source1 -> SM1 [color=red, penwidth=2];
        F_Source2 -> SM2 [color=blue, penwidth=2];
        
        SM2 -> F_Dest1 [label=" Direct Route\nLength = X\nCap = C1", color=blue, penwidth=2];
        SM1 -> SM3 -> F_Dest2 [label=" Congested Route\nLength = X+Δ\nCap = C2 (C1 ≠ C2)", color=red, style=dashed, penwidth=2];
        
        Result2 [label="Transient Glitch Leakage\n(|t| = 56.98, Hiding Fails)", shape=plaintext, fontcolor=red, fillcolor=none];
        F_Dest1 -> Result2 [style=invis];
    }
}
DOT

# Monochrome Version
cat << 'DOT' > diagrams_mono/fig4_routing_failure.dot
digraph G {
    rankdir=TB; compound=true;
    node [shape=box, fontname="Arial"];
    
    subgraph cluster_ASIC {
        label="Theory / ASIC Layout\n(Perfect Symmetry)"; style=dashed;
        Source1 [label="Source 1"]; Source2 [label="Source 2"];
        Dest1 [label="Dest 1"]; Dest2 [label="Dest 2"];
        Source1 -> Dest1 [label=" Length = X\nCapacitance = C", penwidth=2];
        Source2 -> Dest2 [label=" Length = X\nCapacitance = C", penwidth=2];
        Result1 [label="Balanced Power Trace\n(Hiding Succeeds)", shape=plaintext];
        Dest1 -> Result1 [style=invis];
    }

    subgraph cluster_FPGA {
        label="FPGA Reality\n(Automated Switch Matrix Routing)"; style=dashed;
        
        F_Source1 [label="Source 1\n(LUT)"]; F_Source2 [label="Source 2\n(LUT)"];
        F_Dest1 [label="Dest 1\n(LUT)"]; F_Dest2 [label="Dest 2\n(LUT)"];
        
        subgraph cluster_Fabric {
            label="Rigid FPGA Routing Fabric"; style=dotted;
            SM1 [label="Switch\nMatrix 1", shape=Mdiamond];
            SM2 [label="Switch\nMatrix 2", shape=Mdiamond];
            SM3 [label="Switch\nMatrix 3", shape=Mdiamond];
            SM1 -> SM2 [style=dashed];
            SM2 -> SM3 [style=dashed];
        }

        F_Source1 -> SM1 [style=bold];
        F_Source2 -> SM2 [style=bold];
        
        SM2 -> F_Dest1 [label=" Direct Route\nLength = X\nCap = C1", style=bold];
        SM1 -> SM3 -> F_Dest2 [label=" Congested Route\nLength = X+Δ\nCap = C2 (C1 ≠ C2)", style=dashed];
        
        Result2 [label="Transient Glitch Leakage\n(|t| = 56.98, Hiding Fails)", shape=plaintext, style=bold];
        F_Dest1 -> Result2 [style=invis];
    }
}
DOT

# ==========================================
# Compilation
# ==========================================
echo "Compiling all diagrams to PNG and PDF..."
for file in diagrams_color/*.dot; do
    base=$(basename "$file" .dot)
    dot -Tpng -Gdpi=300 "$file" -o "diagrams_color/${base}.png"
    dot -Tpdf "$file" -o "diagrams_color/${base}.pdf"
done

for file in diagrams_mono/*.dot; do
    base=$(basename "$file" .dot)
    dot -Tpng -Gdpi=300 "$file" -o "diagrams_mono/${base}.png"
    dot -Tpdf "$file" -o "diagrams_mono/${base}.pdf"
done

echo "================================================================"
echo "SUCCESS! Monochrome and Color Diagrams generated in respective folders."
echo "================================================================"
