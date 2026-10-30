#!/bin/bash

set -e

# Export environment variables from the job
export CFLAGS="-g -O2 -Werror=pointer-arith -Werror=implicit-function-declaration"
export CCACHE_DIR="/workspace/.ccache"
export CCACHE_COMPRESS=true
export CCACHE_MAXSIZE=1G
export PYTHON=python3
export JOBS=2
export DEBUG=0
export CONFIGURE_FLAGS="--enable-binreloc=no"
export CC="ccache gcc"
export CXX="ccache g++"

# Show environment if DEBUG is enabled
if [ "$DEBUG" == "1" ]; then
    echo "=== Environment ===" >&2
    env | sort
fi

# Configure
echo "=== Running autogen.sh ===" >&2
NOCONFIGURE=1 ./autogen.sh

echo "=== Creating build directory ===" >&2
mkdir -p _build
cd _build

echo "=== Running configure ===" >&2
if ! ../configure $CONFIGURE_FLAGS; then
    echo "Configure failed. Dumping config.log:" >&2
    cat config.log
    exit 1
fi

# Build
echo "=== Building ===" >&2
make -j $JOBS

# Run Tests
echo "=== Running tests ===" >&2
if ! make -j $JOBS check; then
    err="$?"
    echo "make exited with code $err" >&2
    echo "Test suite logs:" >&2
    find . -name 'test-suite.log' -exec cat '{}' ';' >&2
    exit "${err:-1}"
fi

# Run distcheck
echo "=== Running distcheck ===" >&2
make -j $JOBS distcheck DISTCHECK_CONFIGURE_FLAGS="$CONFIGURE_FLAGS"

# Show ccache statistics if DEBUG is enabled
if [ "$DEBUG" == "1" ]; then
    echo "=== ccache statistics ===" >&2
    ccache --show-stats
fi

echo "=== All tests passed ===" >&2