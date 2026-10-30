#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Upgrade pip and install wheel
python -m pip install --upgrade pip wheel

# Install setuptools (version constraint)
python -m pip install "setuptools<80.0.0"

# Install Node.js dependencies
npm ci

# Create packages directory if it doesn't exist
mkdir -p packages/

# Note: The 'dash-packages' artifact from the prior 'build' job should be present in packages/
# If not available, this step assumes wheels are pre-built and placed in packages/
# Alternatively, build Dash from source here if needed.

# Install Dash packages from wheels
# This finds all dash-*.whl files in packages/ and installs them with extras
if find packages -name "dash-*.whl" -print -quit | grep -q .; then
    find packages -name "dash-*.whl" -print -exec sh -c 'pip install "{}[ci,testing,dev]"' \;
else
    echo "Warning: No dash-*.whl files found in packages/. Attempting to install from source..."
    # Fallback: install from current directory if setup.py exists
    if [ -f setup.py ]; then
        pip install -e ".[ci,testing,dev]"
    else
        echo "Error: No wheels found and no setup.py available. Exiting."
        exit 1
    fi
fi

# Build/Setup test components
npm run setup-tests.py

# Run typing tests
pytest tests/compliance/test_typing.py