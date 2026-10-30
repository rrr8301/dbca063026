#!/bin/bash
set -e

# Enable error handling: continue on test failures but report them
exit_code=0

# Export environment variables
export PYTHONOPTIMIZE=1
export REVERSE=--reverse
export COVERAGE_CORE=sysmon
export FORCE_COLOR=1
export PIP_DISABLE_PIP_VERSION_CHECK=1

# Simulate cache hits (no actual cache, so always rebuild)
export GHA_PYTHON_VERSION=3.12
export GHA_LIBAVIF_CACHE_HIT=false
export GHA_LIBIMAGEQUANT_CACHE_HIT=false
export GHA_LIBWEBP_CACHE_HIT=false

echo "=== Build system information ==="
python3 .github/workflows/system-info.py || true

echo "=== Installing Linux dependencies ==="
.ci/install.sh

echo "=== Building ==="
.ci/build.sh

echo "=== Installing test dependencies ==="
python3 -m pip install --break-system-packages --no-cache-dir pytest-reverse

echo "=== Running tests ==="
# Start xvfb for display testing
xvfb-run -s '-screen 0 1024x768x24' bash -c '.ci/test.sh' || exit_code=$?

echo "=== After success ==="
.ci/after_success.sh || true

exit $exit_code