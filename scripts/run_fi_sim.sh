#!/bin/bash
set -e
PROJ_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "[INFO] Running RTL Fault Injection Campaigns via Vivado XSim..."
cd "${PROJ_ROOT}/sim"

xvlog ../rtl/kdm_rolling_key.v ../tb/tb_fi_kdm_rolling_key.v
xelab -debug typical -top tb_fi_kdm_rolling_key -snapshot kdm_fi_snap
xsim kdm_fi_snap -runall
