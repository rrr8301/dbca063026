#!/bin/bash
set -e

# Create and activate Python virtual environment
python3 -m venv --system-site-packages /workspace/.venv
source /workspace/.venv/bin/activate

# Install test requirements
pip install -r /workspace/libcxx/test/requirements.txt

# Run the buildbot
libcxx/utils/ci/run-buildbot generic-cxx26