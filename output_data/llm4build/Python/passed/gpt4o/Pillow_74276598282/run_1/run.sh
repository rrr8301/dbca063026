#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip
pip install -r requirements.txt || true  # Assuming requirements.txt exists

# Install additional dependencies from scripts
.ci/install.sh

# Build the project
.ci/build.sh

# Run tests
if [ "$REVERSE" == "--reverse" ]; then
  pip install pytest-reverse
fi
xvfb-run -s '-screen 0 1024x768x24' sway&
export WAYLAND_DISPLAY=wayland-1
.ci/test.sh

# Run after success script
.ci/after_success.sh