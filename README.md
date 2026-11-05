# Masked+DMR Architecture and TVLA Evaluation Pipeline

This repository contains the complete hardware intellectual property (IP) and pre-silicon evaluation toolchain for the paper: **"Masked+DMR: A Pareto-Optimal Key Derivation Architecture for Combined SCA and FI Resilience on FPGAs"** (Currently under double-blind peer review for IEEE HOST 2026).

## Overview
The provided artifacts allow researchers to reproduce the pre-silicon Test Vector Leakage Assessment (TVLA) methodology and verify the hardware costs (Power, Performance, Area) of the proposed Masked+DMR architecture targeting the Kintex UltraScale+ FPGA (`xcku5p-ffvb676-2-e`).

Unlike standard RTL simulations, this repository utilizes an automated pipeline to extract back-annotated Standard Delay Format (SDF) timing delays from Xilinx Vivado. This proves that theoretical Dual-Rail Hiding countermeasures fail on commercial FPGAs due to routing capacitance asymmetries.

## Repository Structure
* `/rtl`: Parameterized Verilog RTL for all evaluated branches (Baseline, Masked+DMR, Hiding, Morphing).
* `/tb`: Cycle-accurate testbenches for functional verification, fault-injection ($<8$ns alarm latency), and TVLA.
* `/scripts`: TCL and Bash scripts for Vivado synthesis, SDF extraction, and XSim batch execution.
* `/constraints.xdc`: Physical constraints and 125 MHz clock definitions for the target Kintex UltraScale+ device.
* `/tvla`: Memory-optimized Python scripts to parse gigabyte-scale VCDs and calculate Welch's $t$-test.
* `/figures`: Pre-compiled architectural block diagrams and empirical Pareto/TVLA plots.

## Double-Blind Compliance Notice
This repository has been fully sanitized to comply with the double-blind review policies of IEEE HOST. All author names, institutional affiliations, and funding acknowledgments have been removed.
