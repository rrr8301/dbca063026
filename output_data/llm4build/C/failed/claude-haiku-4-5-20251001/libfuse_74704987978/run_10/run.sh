#!/bin/bash
set -e

# Activate virtual environment
source /opt/venv/bin/activate

# Navigate to workspace
cd /workspace

# Disable sanitizers - the clang linker in this container doesn't support sanitizer flags
# Pass this to Meson via environment variable
export MESON_ARGS="-Db_sanitize=none"

# Run the build and test script
if [ -f ./test/ci-build.sh ]; then
    # Execute with MESON_ARGS available to subshells
    bash -c 'MESON_ARGS="$MESON_ARGS" ./test/ci-build.sh'
else
    echo "Error: test/ci-build.sh not found"
    exit 1
fi