#!/bin/bash

# Activate Python environment
python3.12 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip

# Check if requirements.txt exists before attempting to install
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
fi

# Install additional dependencies from scripts
if [ -f ".ci/install.sh" ]; then
    # Remove sudo from the install script
    sed -i 's/sudo //g' .ci/install.sh
    bash .ci/install.sh
fi

# Build the project
if [ -f ".ci/build.sh" ]; then
    bash .ci/build.sh
fi

# Run tests
if [ "$REVERSE" == "--reverse" ]; then
    pip install pytest-reverse
fi

# Start Xvfb and sway
XDG_RUNTIME_DIR=/tmp/runtime-dir
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
export XDG_RUNTIME_DIR

xvfb-run -s '-screen 0 1024x768x24' sway --unsupported-gpu &
export WAYLAND_DISPLAY=wayland-1

# Check if test script exists before running
if [ -f ".ci/test.sh" ]; then
    bash .ci/test.sh
fi

# Run after success script
if [ -f ".ci/after_success.sh" ]; then
    bash .ci/after_success.sh
fi