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

# Test with xvfb-run (simpler and more reliable than manual Xvfb + sway)
echo "=== Running Tests ==="
export REVERSE="--reverse"
xvfb-run -s '-screen 0 1024x768x24' .ci/test.sh