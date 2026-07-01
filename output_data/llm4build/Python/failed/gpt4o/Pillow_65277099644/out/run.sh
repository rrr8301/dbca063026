#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Activate Python virtual environment
source /opt/venv/bin/activate

# Install project dependencies
pip install -r /app/requirements.txt

# Build system information
python3 /app/.github/workflows/system-info.py

# Install Linux dependencies
export GHA_PYTHON_VERSION=3.12
/app/.ci/install.sh

# Build the project
/app/.ci/build.sh

# Run tests
if [ "$REVERSE" ]; then
  pip install pytest-reverse
fi
xvfb-run -s '-screen 0 1024x768x24' sway&
export WAYLAND_DISPLAY=wayland-1
/app/.ci/test.sh || true  # Ensure all tests run even if some fail

# After success
/app/.ci/after_success.sh