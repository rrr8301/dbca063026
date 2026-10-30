#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Build the project
echo "Building NumPy"
spin build --clean -- -Dallow-noblas=true -Dcpu-baseline=none -Dcpu-dispatch=none

# Display Meson log
echo "Meson Log"
cat build/meson-logs/meson-log.txt

# Run tests
echo "Running Tests"
spin test -- --durations=10 --timeout=600 || true  # Ensure all tests run even if some fail