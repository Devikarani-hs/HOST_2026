import os
import re

# Target the active rtl folder where the files currently reside
target_dirs = ['rtl', 'rtl_backup']
patched_count = 0

# Regex to safely replace the asynchronous reset block with a synchronous BRAM block
pattern = re.compile(r'always\s*@\s*\(\s*posedge\s+clk\s+or\s+negedge\s+rst_n\s*\)\s*begin\s+(?:if\s*\(\s*!rst_n\s*\).*?history_rdata\s*<=\s*[^;]+;.*?else\s*begin|if\s*\(\s*!rst_n\s*\)\s*begin.*?history_rdata\s*<=\s*[^;]+;.*?end\s*else\s*begin)\s*if\s*\(\s*s_axis_tvalid\s*&&\s*s_axis_tready\s*\)\s*history_ram\s*\[\s*wr_ptr\s*\]\s*<=\s*s_axis_tdata\s*;\s*history_rdata\s*<=\s*history_ram\s*\[\s*rd_ptr\s*\]\s*;\s*end\s*end', re.DOTALL)

replacement = """// STRICT BRAM INFERENCE (No Asynchronous Reset)
    always @(posedge clk) begin
        if (s_axis_tvalid && s_axis_tready) history_ram[wr_ptr] <= s_axis_tdata;
        history_rdata <= history_ram[rd_ptr];
    end"""

for d in target_dirs:
    if not os.path.exists(d): continue
    for filename in os.listdir(d):
        if filename.endswith('.v'):
            filepath = os.path.join(d, filename)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Execute the replacement
            new_content, count = pattern.subn(replacement, content)
            if count > 0:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"[SUCCESS] Patched BRAM logic in {filepath}")
                patched_count += 1

if patched_count == 0:
    print("\n[ERROR] No files were patched. Please check if the .v files are in the rtl/ directory.")
else:
    print(f"\nSuccessfully patched {patched_count} files for BRAM inference!")
