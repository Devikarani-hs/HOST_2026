import sys
from scipy.stats import ttest_ind

fixed_file = sys.argv[1]
random_file = sys.argv[2]
design_name = sys.argv[3]

try:
    with open(fixed_file, 'r') as f:
        fixed_traces = [float(x.strip()) for x in f.readlines()]
    with open(random_file, 'r') as f:
        random_traces = [float(x.strip()) for x in f.readlines()]

    # Perform Welch's t-test
    t_stat, p_val = ttest_ind(fixed_traces, random_traces, equal_var=False)
    max_t = abs(t_stat)

    print(f"[{design_name}] Max |t|-value: {max_t:.2f}")
    if max_t > 4.5:
        print(f"[{design_name}] Result: FAILED (Significant Leakage Detected)\n")
    else:
        print(f"[{design_name}] Result: PASSED (SCA Secure)\n")

except FileNotFoundError:
    print(f"[{design_name}] Error: Trace files not found.")
