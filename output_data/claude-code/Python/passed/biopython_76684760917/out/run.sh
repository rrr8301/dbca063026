#!/usr/bin/env bash
set -e

# Start MySQL server
echo "Starting MySQL server..."
service mysql start
sleep 2

# Debug info
echo "Python version:"
python --version
echo ""
echo "Installed packages:"
python -m pip list
echo ""

# Install from source with ASAN
echo "Installing biopython from source with ASAN..."
export CC="gcc -fsanitize=address -fsanitize=undefined -g"
python -m pip install .

# Run test suite
echo "Running test suite..."
cd Tests

# Setup environment for ASAN
export PYTHONMALLOC=debug
export ASAN_OPTIONS="detect_leaks=0"
LIBASAN=$(realpath "$(gcc -print-file-name=libasan.so)")
LIBSTDCXX=$(realpath "$(gcc -print-file-name=libstdc++.so)")
export LD_PRELOAD="${LIBASAN} ${LIBSTDCXX}"

# Run tests with coverage
coverage run --source Bio,BioSQL run_tests.py --offline
coverage xml

echo ""
echo "FINAL_STATUS = SUCCESS"
