#!/bin/bash
set -e

# Create and activate Python virtual environment
python3 -m venv /workspace/venv
source /workspace/venv/bin/activate

# Upgrade pip and install packages in the virtual environment
python3 -m pip install --upgrade pip
python3 -m pip install pytest pytest-html pytest-xdist ruamel.yaml