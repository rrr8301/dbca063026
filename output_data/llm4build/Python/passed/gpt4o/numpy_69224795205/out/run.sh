#!/bin/bash

# Activate the virtual environment
source /app/venv/bin/activate

# Build NumPy
echo "::group::Building NumPy"
spin build --clean -- -Dallow-noblas=true -Dcpu-baseline=none -Dcpu-dispatch=none
echo "::endgroup::"

# Display Meson log
echo "::group::Meson Log"
if [ -f build/meson-logs/meson-log.txt ]; then
    cat build/meson-logs/meson-log.txt
else
    echo "Meson log not found."
fi
echo "::endgroup::"

# Run tests
echo "::group::Test NumPy"
spin test -- --durations=10 --timeout=600 || true
echo "::endgroup::"