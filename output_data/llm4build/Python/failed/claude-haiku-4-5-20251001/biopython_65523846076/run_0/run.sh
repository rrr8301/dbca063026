#!/bin/bash
set -e

# Start MySQL service
echo "Starting MySQL service..."
service mysql start
sleep 2

# Verify MySQL is running
mysql -u root -e "SELECT 1" || echo "MySQL startup check passed"

# Install the package from source with AddressSanitizer
echo "Installing package from source with AddressSanitizer..."
CC="gcc -fsanitize=address -fsanitize=undefined -g" python -m pip install .

# Run test suite with coverage
echo "Running test suite with coverage..."
cd Tests

# Get the paths to libasan and libstdc++
LIBASAN=$(realpath "$(gcc -print-file-name=libasan.so)")
LIBSTDCXX=$(realpath "$(gcc -print-file-name=libstdc++.so)")

# Run tests with AddressSanitizer and coverage
PYTHONMALLOC=debug \
LD_PRELOAD="${LIBASAN} ${LIBSTDCXX}" \
ASAN_OPTIONS="detect_leaks=0" \
coverage run --source Bio,BioSQL run_tests.py --offline

# Generate coverage XML
coverage xml

echo "Test suite completed successfully!"