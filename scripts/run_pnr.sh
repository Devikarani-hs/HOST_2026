#!/bin/bash
set -e
PROJ_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "[INFO] Running Vivado Batch Synthesis and PnR..."
cd "${PROJ_ROOT}"
vivado -mode batch -source scripts/synth_pnr.tcl -nolog -nojournal
