#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Check if the requirements file exists and install dependencies if it does
REQUIREMENTS_FILE="scipy/subprojects/pyprima/pyprima/pyprima/tests/requirements.txt"
if [ -f "$REQUIREMENTS_FILE" ]; then
    pip install -r "$REQUIREMENTS_FILE"
else
    echo "Warning: Requirements file not found at $REQUIREMENTS_FILE. Skipping dependency installation."
fi

# Setup build and install SciPy
spin build --release

# Ensure build directory exists
mkdir -p build-install

# Run checks and tests
ccache --evict-older-than 1d
ccache -s
spin check --installed-files --no-build
spin check --symbol-hiding --no-build
rm -rf build-install
spin build --tags=runtime,python-runtime,devel
python tools/check_installation.py build-install --no-tests
rm -rf build-install
spin build --tags=runtime,python-runtime,devel,tests
spin check --installed-files --no-build
spin check --xp-markers --no-build
ninja -C build -t missingdeps

# Test SciPy
export OMP_NUM_THREADS=2
spin test -j3 -- --durations 10 --timeout=60