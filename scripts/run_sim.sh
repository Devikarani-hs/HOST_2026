#!/bin/bash
set -e
PROJ_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
echo "[INFO] Running RTL Simulation via Vivado XSim..."
cd "${PROJ_ROOT}/sim"

xvlog ../rtl/kdm_rolling_key.v ../tb/tb_kdm_rolling_key.v
xelab -debug typical -top tb_kdm_rolling_key -snapshot kdm_sim_snap
xsim kdm_sim_snap -runall
