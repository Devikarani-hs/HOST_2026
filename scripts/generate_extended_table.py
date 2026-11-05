# Extended PPA Results (Replace 'Fmax' and 'Latency' with your Vivado timing report data)
ppa_results = [
    {"arch": "Unprotected Baseline", "luts": 482,  "ffs": 536,  "bram": 1, "dsp": 0, "fmax": 250.0, "latency": 10, "power": 9.4,  "tput": 1148},
    {"arch": "Branch 1: Masked+DMR", "luts": 1942, "ffs": 1896, "bram": 1, "dsp": 0, "fmax": 125.0, "latency": 15, "power": 18.0, "tput": 574},
    {"arch": "Branch 2: Hiding+DMR", "luts": 1205, "ffs": 1102, "bram": 1, "dsp": 0, "fmax": 140.0, "latency": 12, "power": 14.2, "tput": 574},
    {"arch": "Branch 3: Morphing+DMR","luts": 1110, "ffs": 1054, "bram": 1, "dsp": 0, "fmax": 135.0, "latency": 18, "power": 13.5, "tput": 574}
]

tex_content = r"""\begin{table*}[t]
\centering
\caption{Comprehensive Implementation & Efficiency Metrics on Kintex UltraScale+ (xcku5p)}
\label{tab:ppa_extended}
\resizebox{\textwidth}{!}{%
\begin{tabular}{@{}lcccccccccc@{}}
\toprule
\textbf{Architecture} & \textbf{LUTs} & \textbf{FFs} & \textbf{BRAM / DSP} & \textbf{$F_{max}$ (MHz)} & \textbf{Latency (Cycles)} & \textbf{Power (mW)} & \textbf{T-put (Mbps)} & \textbf{Efficiency (Mbps/LUT)} & \textbf{Energy (pJ/bit)} \\ \midrule
"""

for r in ppa_results:
    # Calculate Efficiencies automatically
    eff_area = round(r['tput'] / r['luts'], 3)
    # Energy per bit (pJ/bit) = Power (mW) / Throughput (Mbps)
    eff_energy = round(r['power'] / r['tput'] * 1000, 2) # *1000 to convert to pJ
    
    tex_content += f"{r['arch']} & {r['luts']} & {r['ffs']} & {r['bram']} / {r['dsp']} & {r['fmax']} & {r['latency']} & {r['power']} & {r['tput']} & {eff_area} & {eff_energy} \\\\\n"

tex_content += r"""\bottomrule
\end{tabular}%
}
\end{table*}
"""

with open("paper_extended_table.tex", "w") as f:
    f.write(tex_content)

print("[SUCCESS] Extended Table with Delay/Fmax, Latency, and Efficiency saved to paper_extended_table.tex")
