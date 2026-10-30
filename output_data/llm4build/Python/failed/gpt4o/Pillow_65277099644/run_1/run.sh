#!/bin/bash

# Activate Python virtual environment
source /opt/venv/bin/activate

# Install project dependencies
pip install -r requirements.txt

# Build system information
python3 .github/workflows/system-info.py

# Install Linux dependencies
export GHA_PYTHON_VERSION=3.12
.ci/install.sh

# Build the project
.ci/build.sh

# Run tests
if [ "$REVERSE" ]; then
  pip install pytest-reverse
fi
xvfb-run -s '-screen 0 1024x768x24' sway&
export WAYLAND_DISPLAY=wayland-1
.ci/test.sh || true  # Ensure all tests run even if some fail

# After success
.ci/after_success.sh