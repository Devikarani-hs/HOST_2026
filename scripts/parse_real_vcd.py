import sys
import numpy as np
from scipy.stats import ttest_ind

design_name = sys.argv[1]

def extract_toggles(vcd_path):
    cycle_toggles = []
    toggles = 0
    try:
        with open(vcd_path, 'r') as f:
            for line in f:
                if line.startswith('#'):
                    if toggles > 0:
                        cycle_toggles.append(toggles)
                    toggles = 0
                elif line[0] in ('0', '1', 'b', 'r'):
                    toggles += 1
        return np.array(cycle_toggles)
    except Exception as e:
        print(f"Error reading {vcd_path}: {e}")
        return np.array([])

print(f"[{design_name}] Parsing physical wire toggles from Fixed VCD...")
fixed_power = extract_toggles('traces/real_fixed.vcd')

print(f"[{design_name}] Parsing physical wire toggles from Random VCD...")
random_power = extract_toggles('traces/real_random.vcd')

if len(fixed_power) == 0 or len(random_power) == 0:
    print(f"[{design_name}] FAILED to extract traces.")
    sys.exit(1)

# Ensure equal array lengths for Welch's t-test
min_len = min(len(fixed_power), len(random_power))
fixed_power = fixed_power[:min_len]
random_power = random_power[:min_len]

# Welch's T-Test
t_stat, p_val = ttest_ind(fixed_power, random_power, equal_var=False)
max_t = np.max(np.abs(t_stat))

print(f"[{design_name}] REAL GATE-LEVEL Max |t|-value: {max_t:.2f}")
if max_t > 4.5:
    print(f"[{design_name}] Result: FAILED (Physical Leakage Detected)\n")
else:
    print(f"[{design_name}] Result: PASSED (SCA Secure)\n")
