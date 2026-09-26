#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Install project dependencies
pip install -r scipy/subprojects/pyprima/pyprima/pyprima/tests/requirements.txt

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