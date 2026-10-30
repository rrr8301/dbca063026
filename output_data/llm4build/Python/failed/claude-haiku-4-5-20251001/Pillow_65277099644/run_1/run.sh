#!/bin/bash
set -e

# Print system information
echo "=== System Information ==="
python3 .github/workflows/system-info.py

# Install Linux dependencies
echo "=== Installing Linux Dependencies ==="
export GHA_PYTHON_VERSION=3.12
export GHA_LIBAVIF_CACHE_HIT=false
export GHA_LIBIMAGEQUANT_CACHE_HIT=false
export GHA_LIBWEBP_CACHE_HIT=false
.ci/install.sh

# Build
echo "=== Building ==="
.ci/build.sh

# Test with Wayland display
echo "=== Running Tests ==="
export WAYLAND_DISPLAY=wayland-1
export REVERSE="--reverse"

# Start xvfb and sway in the background
Xvfb :99 -screen 0 1024x768x24 &
XVFB_PID=$!
sleep 2

# Start sway with the virtual display
DISPLAY=:99 sway &
SWAY_PID=$!
sleep 2

# Run tests
DISPLAY=:99 WAYLAND_DISPLAY=wayland-1 .ci/test.sh
TEST_EXIT_CODE=$?

# Clean up background processes
kill $SWAY_PID 2>/dev/null || true
kill $XVFB_PID 2>/dev/null || true

exit $TEST_EXIT_CODE