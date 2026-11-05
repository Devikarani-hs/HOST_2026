import os

tb_path = 'tb/tb_real_tvla.v'

with open(tb_path, 'r') as f:
    lines = f.readlines()

out_lines = []
for line in lines:
    # 1. Clean up the previous inline declarations
    line = line.replace('integer dummy = ', '')
    
    # 2. Assign $value$plusargs to dummy without inline declaration
    if '$value$plusargs' in line and 'dummy =' not in line:
        line = line.replace('$value$plusargs', 'dummy = $value$plusargs')
        
    out_lines.append(line)

# 3. Safely declare 'integer dummy;' once at the top of the module
for i, line in enumerate(out_lines):
    if line.strip().startswith('module '):
        # Insert the declaration right after the module definition
        out_lines.insert(i + 1, '    integer dummy;\n')
        break

with open(tb_path, 'w') as f:
    f.writelines(out_lines)

print("Testbench patched successfully.")
