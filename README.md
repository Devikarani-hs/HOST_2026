# Masked+DMR Architecture and TVLA Evaluation Pipeline

This repository contains the complete hardware intellectual property (IP) and pre-silicon evaluation toolchain for the paper: **"Masked+DMR: A Pareto-Optimal Key Derivation Architecture for Combined SCA and FI Resilience on FPGAs"** (Currently under double-blind peer review for IEEE HOST 2026).

## Overview
The provided artifacts allow researchers to reproduce the pre-silicon Test Vector Leakage Assessment (TVLA) methodology and verify the hardware costs (Power, Performance, Area) of the proposed Masked+DMR architecture targeting the Kintex UltraScale+ FPGA (`xcku5p-ffvb676-2-e`).

Unlike standard RTL simulations, this repository utilizes an automated pipeline to extract back-annotated Standard Delay Format (SDF) timing delays from Xilinx Vivado. This proves that theoretical Dual-Rail Hiding countermeasures fail on commercial FPGAs due to routing capacitance asymmetries.

## Repository Structure

The repository is organized to support push-button reproduction of the results presented in the manuscript.

### `/rtl` (Hardware Design Files)
Contains the parameterized Verilog RTL for all evaluated branches:
*   `Baseline`: Unprotected Key Derivation Module.
*   `Masked+DMR`: Proposed architecture featuring first-order boolean masking, hardened BRAMs, glitch-mitigation register barriers, and Dual Modular Redundancy (DMR).
*   `Hiding+DMR`: Architecture evaluating theoretical Dual-Rail Capacitive Balancing.
*   `Morphing+DMR`: Architecture evaluating Temporal Morphing countermeasures.
*   `prng_lfsr32.v`: Internal PRNG for mask generation.

### `/tb` (Testbenches)
Cycle-accurate testbenches for functional verification and fault-injection simulation:
*   `tb_kdm_rolling_key.v`: Primary functional testbench for Key Derivation.
*   `tb_fi_kdm_rolling_key.v`: Evaluates the hardware fault alarm latency (< 8 ns) against clock/laser fault injection models.
*   `tb_tvla.v` / `tb_real_tvla.v`: Testbenches for executing fixed-vs-random trace generation.
*   `tb_ppa_saif.v`: Testbench for generating Switching Activity Interchange Format (SAIF) files for accurate dynamic power estimation.

### `/scripts` (Automation and EDA Toolchain)
Bash and TCL scripts for automating the Vivado synthesis and XSim workflows:
*   `synth_pnr.tcl`: Vivado script for synthesis, implementation, and SDF/Netlist extraction.
*   `xsim_vcd.tcl` / `xsim_saif.tcl`: XSim batch scripts for automated waveform and switching activity dumps.
*   `run_tvla_100k.sh`: Automates the generation of 100,000 simulated traces.
*   `verify_all_raw.sh` / `run_xsim_debug.sh`: Validation scripts.

### `/constraints.xdc` (Physical Constraints)
*   Contains the physical constraints and clock definitions targeting the `xcku5p-ffvb676-2-e` Kintex UltraScale+ device.

### `/tvla` (Python TVLA Evaluation Pipeline)
*   Custom, memory-optimized Python scripts designed to parse gigabyte-scale Value Change Dump (VCD) files. 
*   Extracts clock-cycle accurate Hamming Distance power models to calculate the Welch's $t$-test values reported in the manuscript (Table II).

### `/figures` & `/graphs` (Artifacts and Results)
Contains the visual data supporting the paper's claims:
*   Pre-compiled PDF and PNG block diagrams detailing the hardware architectures.
*   Empirical Pareto frontier charts showing PPA vs. Security trade-offs.
*   TVLA progression plots across 100,000 traces.
*   Raw numerical outputs and extended LaTeX tables.

## Reproduction Steps

**Prerequisites:** 
*   Xilinx Vivado (Version 2024.1 or compatible).
*   Python 3.x with NumPy and SciPy libraries (for TVLA calculations).
*   Ubuntu Linux environment.

**Step 1: Implementation and SDF Extraction**
Execute the Vivado build script to synthesize the design, perform place-and-route, and extract the SDF timing file.
```bash
vivado -mode batch -source scripts/synth_pnr.tcl
```

**Step 2: Gate-Level Simulation**
Run the automated bash script to execute the XSim testbenches utilizing the extracted SDF delays. This generates the VCD traces.
```bash
./scripts/run_tvla_100k.sh
```

**Step 3: TVLA Evaluation**
Run the Python evaluation scripts to parse the VCD traces and calculate the maximum |t|-value.
```bash
python3 tvla/evaluate_traces.py
```

## Double-Blind Compliance Notice
This repository has been fully sanitized to comply with the double-blind review policies of IEEE HOST. All author names, institutional affiliations, and funding acknowledgments have been removed from the source code, scripts, and documentation. Upon acceptance, this repository will be transferred to a permanent, public GitHub repository.
