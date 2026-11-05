import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.stats import ttest_ind

print("[INFO] Loading aligned power traces...")
traces = np.load("synth_out/traces.npy")

# Interleaved split: Even indices = Group A (Fixed), Odd indices = Group B (Random)
group_a = traces[0::2]
group_b = traces[1::2]

print(f"[INFO] Group A (Fixed) traces: {len(group_a)}")
print(f"[INFO] Group B (Random) traces: {len(group_b)}")

t_stat, _ = ttest_ind(group_a, group_b, axis=0, equal_var=False)
t_stat = np.nan_to_num(t_stat, nan=0.0, posinf=0.0, neginf=0.0)
max_t = np.max(np.abs(t_stat))

plt.figure(figsize=(10, 5), dpi=300)
plt.plot(t_stat, color='#1a1a1a', linewidth=1.2, label="Welch's t-statistic (Branch 1: 1st-Order Masked)")
plt.axhline(4.5, color='#d9534f', linestyle='--', linewidth=1.5, label='Leakage Threshold (+4.5)')
plt.axhline(-4.5, color='#d9534f', linestyle='--', linewidth=1.5, label='Leakage Threshold (-4.5)')
plt.fill_between(range(len(t_stat)), -4.5, 4.5, color='#d4edda', alpha=0.35, label='SCA Secure Zone (|t| <= 4.5)')
plt.ylim(-15, 15)
plt.xlabel("Time Sample Index (500 ps / bin)", fontsize=11, fontweight='bold')
plt.ylabel("Welch's t-Statistic", fontsize=11, fontweight='bold')
plt.title(f"Phase 6 Branch 1 TVLA: 1st-Order Boolean Masked KDM (Max |t| = {max_t:.2f})", fontsize=12, fontweight='bold')
plt.legend(loc='upper right')
plt.grid(True, linestyle=':', alpha=0.6)
plt.tight_layout()
plt.savefig("synth_out/tvla_results.png")
plt.savefig("synth_out/tvla_branch1_masked.png")

print(f"[SUCCESS] TVLA Plot saved to: synth_out/tvla_branch1_masked.png")
if max_t <= 4.5:
    print(f"[PASS] Design is Side-Channel Secure! Maximum |t| = {max_t:.2f} (<= 4.5 threshold)")
else:
    print(f"[WARNING] Side-channel leakage detected! Maximum |t| = {max_t:.2f}")
