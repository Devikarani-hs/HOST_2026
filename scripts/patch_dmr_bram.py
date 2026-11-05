import os
import re

target_dir = 'rtl'
patched_count = 0

# This regex specifically targets the async reset block while preserving the !fi_alarm logic
pattern = re.compile(
    r'always\s*@\s*\(\s*posedge\s+clk\s+or\s+negedge\s+rst_n\s*\)\s*begin\s+'
    r'if\s*\(\s*!rst_n\s*\)\s*begin\s+'
    r'history_rdata\s*<=\s*[^;]+;\s+'
    r'end\s*else\s*if\s*\(\s*!fi_alarm\s*\)\s*begin',
    re.DOTALL
)

replacement = """// STRICT BRAM INFERENCE (No Asynchronous Reset)
    always @(posedge clk) begin
        if (!fi_alarm) begin"""

for filename in os.listdir(target_dir):
    if filename.endswith('.v'):
        filepath = os.path.join(target_dir, filename)
        with open(filepath, 'r') as f:
            content = f.read()
        
        new_content, count = pattern.subn(replacement, content)
        if count > 0:
            with open(filepath, 'w') as f:
                f.write(new_content)
            print(f"[SUCCESS] Patched DMR BRAM logic in {filename}")
            patched_count += 1

if patched_count == 0:
    print("\n[ERROR] No matching logic found to patch. Please check the files.")
else:
    print(f"\nSuccessfully patched {patched_count} DMR files for BRAM inference!")
