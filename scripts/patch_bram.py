import os
import re

rtl_dir = 'rtl_backup'
pattern = re.compile(r'always\s*@\s*\(\s*posedge\s+clk\s+or\s+negedge\s+rst_n\s*\)\s*begin\s+(?:if\s*\(\s*!rst_n\s*\).*?history_rdata\s*<=\s*[^;]+;.*?else\s*begin|if\s*\(\s*!rst_n\s*\)\s*begin.*?history_rdata\s*<=\s*[^;]+;.*?end\s*else\s*begin)\s*if\s*\(\s*s_axis_tvalid\s*&&\s*s_axis_tready\s*\)\s*history_ram\s*\[\s*wr_ptr\s*\]\s*<=\s*s_axis_tdata\s*;\s*history_rdata\s*<=\s*history_ram\s*\[\s*rd_ptr\s*\]\s*;\s*end\s*end', re.DOTALL)

replacement = """// STRICT BRAM INFERENCE (No Asynchronous Reset on RAM Output)
    always @(posedge clk) begin
        if (s_axis_tvalid && s_axis_tready) history_ram[wr_ptr] <= s_axis_tdata;
        history_rdata <= history_ram[rd_ptr];
    end"""

for filename in os.listdir(rtl_dir):
    if filename.endswith('.v'):
        filepath = os.path.join(rtl_dir, filename)
        with open(filepath, 'r') as f:
            content = f.read()
        
        new_content, count = pattern.subn(replacement, content)
        if count > 0:
            with open(filepath, 'w') as f:
                f.write(new_content)
            print(f"[SUCCESS] Patched {filename} for physical BRAM inference.")
        else:
            print(f"[SKIP] No matching async RAM block found in {filename}.")
