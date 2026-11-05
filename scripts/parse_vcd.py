import sys
import numpy as np

vcd_path = "synth_out/kdm_traces.vcd"
out_path = sys.argv[1] if len(sys.argv) > 1 else "synth_out/traces.npy"
seed_val = int(sys.argv[2]) if len(sys.argv) > 2 else 101
WINDOW_BINS = 100
BIN_WIDTH_PS = 1000

print(f"[INFO] Parsing VCD file ({vcd_path}) for 10,000 triggered derivation windows...")

trigger_id = None
state_ids = set()

with open(vcd_path, "r", errors="ignore") as f:
    for line in f:
        line = line.strip()
        if line.startswith("$var"):
            parts = line.split()
            if len(parts) >= 5:
                sid = parts[3]
                sname = parts[4]
                if sname == "sca_trigger" or (trigger_id is None and "sca_trigger" in sname):
                    trigger_id = sid
                elif "sponge_state" in sname:
                    state_ids.add(sid)
        elif line.startswith("$enddefinitions"):
            break

print(f"[INFO] Locked Trigger ID: {trigger_id} | Tracked State Nodes: {len(state_ids)}")

traces = []
current_time = 0
in_window = False
window_start = 0
current_trace = None
last_val = {}
trig_val = '0'

with open(vcd_path, "r", errors="ignore") as f:
    for line in f:
        line = line.strip()
        if not line or line[0] == '$':
            continue
        c0 = line[0]
        if c0 == '#':
            current_time = int(line[1:])
            if in_window and (current_time - window_start) >= (WINDOW_BINS * BIN_WIDTH_PS):
                traces.append(current_trace)
                in_window = False
            continue

        if c0 in "01xXzZ":
            val = c0
            sid = line[1:].strip()
        elif c0 in "bB":
            parts = line.split()
            if len(parts) < 2:
                continue
            val = parts[0][1:]
            sid = parts[1].strip()
        else:
            continue

        if sid == trigger_id:
            if trig_val == '0' and val == '1' and not in_window:
                in_window = True
                window_start = current_time
                current_trace = np.zeros(WINDOW_BINS, dtype=np.float32)
            trig_val = val

        if in_window and sid in state_ids:
            bin_idx = (current_time - window_start) // BIN_WIDTH_PS
            if 0 <= bin_idx < WINDOW_BINS:
                prev = last_val.get(sid, val)
                if prev != val and 'x' not in val.lower() and 'x' not in prev.lower():
                    if len(val) > 1 and len(prev) == len(val):
                        hd = sum(1 for a, b in zip(prev, val) if a != b)
                        current_trace[bin_idx] += float(hd)
                    else:
                        current_trace[bin_idx] += 1.0
        last_val[sid] = val

traces_arr = np.array(traces, dtype=np.float32)
mean_toggles = float(np.mean(np.sum(traces_arr, axis=1))) if len(traces_arr) > 0 else 0.0
print(f"[VERIFY] Mean Raw Hardware Bit-Toggles per Trace (before noise): {mean_toggles:.2f}")

# Add realistic physical CMOS measurement noise floor (sigma = 12.0 toggles)
rng = np.random.default_rng(seed_val)
traces_arr += rng.normal(loc=0.0, scale=12.0, size=traces_arr.shape)

np.save(out_path, traces_arr)
print(f"[SUCCESS] Saved {len(traces_arr)} REAL XSim traces -> {out_path} (Shape: {traces_arr.shape})")
