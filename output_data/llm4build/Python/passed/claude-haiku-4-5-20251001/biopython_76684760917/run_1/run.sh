#!/bin/bash
set -e

# Start MySQL service
echo "Starting MySQL service..."
service mysql start || true
sleep 2

# Verify Python installation
echo "Python version:"
python3.14 --version

# List installed packages
echo "Installed pip packages:"
python3.14 -m pip list

# Navigate to Tests directory and run test suite
cd /workspace/Tests

echo "Running test suite with coverage..."
PYTHONMALLOC=debug \
LD_PRELOAD="$(realpath "$(gcc -print-file-name=libasan.so)") $(realpath "$(gcc -print-file-name=libstdc++.so)")" \
ASAN_OPTIONS="detect_leaks=0" \
python3.14 -m coverage run --source Bio,BioSQL run_tests.py --offline

echo "Generating coverage XML report..."
python3.14 -m coverage xml

echo "Test suite completed successfully!"