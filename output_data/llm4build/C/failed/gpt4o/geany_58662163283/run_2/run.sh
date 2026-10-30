#!/bin/bash

# Set environment variables
export CFLAGS="-g -O2 -Werror=pointer-arith -Werror=implicit-function-declaration"
export CCACHE_DIR="/app/.ccache"
export CCACHE_COMPRESS=true
export CCACHE_MAXSIZE=1G
export PYTHON="python3"
export JOBS=2
export DEBUG=0
export CONFIGURE_FLAGS="--enable-binreloc=no"
export CC="ccache gcc"
export CXX="ccache g++"

# Prepare ccache timestamp
timestamp=$(date +%Y-%m-%d-%H-%M)

# Show environment if DEBUG is set
if [ "$DEBUG" -eq 1 ]; then
  env | sort
fi

# Ensure the autogen.sh script is executable
chmod +x autogen.sh

# Configure
NOCONFIGURE=1 ./autogen.sh
mkdir -p _build
cd _build

# Ensure configure script is executable
chmod +x ../configure

../configure $CONFIGURE_FLAGS || { cat config.log; exit 1; }

# Build
make -j $JOBS

# Run Tests
make -j $JOBS check || {
  err="$?"
  echo "make exited with code $err" >&2
  echo "Test suite logs:" >&2
  find . -name 'test-suite.log' -exec cat '{}' ';' >&2
  exit "${err:-1}"
}

# Run distcheck
make -j $JOBS distcheck DISTCHECK_CONFIGURE_FLAGS="$CONFIGURE_FLAGS"

# Show ccache statistics if DEBUG is set
if [ "$DEBUG" -eq 1 ]; then
  ccache --show-stats
fi