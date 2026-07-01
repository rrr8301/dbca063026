#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Build the project
echo "Building NumPy"
spin build --clean -- -Dallow-noblas=true -Dcpu-baseline=none -Dcpu-dispatch=none

# Display Meson log
echo "Meson Log"
if [ -f build/meson-logs/meson-log.txt ]; then
    cat build/meson-logs/meson-log.txt
else
    echo "Meson log not found."
fi

# Run tests
echo "Running Tests"
spin test -- --durations=10 --timeout=600 || true  # Ensure all tests run even if some fail