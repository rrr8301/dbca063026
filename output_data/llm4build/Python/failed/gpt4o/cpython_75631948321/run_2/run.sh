#!/bin/bash

# Set up environment variables
export MULTISSL_DIR=/workspace/multissl
export OPENSSL_DIR=/workspace/multissl/openssl/3.5.6
export LD_LIBRARY_PATH=/workspace/multissl/openssl/3.5.6/lib

# Setup directory envs for out-of-tree builds
export CPYTHON_RO_SRCDIR=$(realpath -m "/workspace/../cpython-ro-srcdir")
export CPYTHON_BUILDDIR=$(realpath -m "/workspace/../cpython-builddir")

# Create directories for read-only out-of-tree builds
mkdir -p "$CPYTHON_RO_SRCDIR" "$CPYTHON_BUILDDIR"

# Bind mount sources read-only (simulated by copying)
rsync -a --exclude='*/.git/*' /workspace/ "$CPYTHON_RO_SRCDIR/"

# Ensure the configure script is present
if [ ! -f "$CPYTHON_RO_SRCDIR/configure" ]; then
    echo "Error: configure script not found in $CPYTHON_RO_SRCDIR"
    exit 1
fi

# Configure CPython out-of-tree
cd "$CPYTHON_BUILDDIR"
../cpython-ro-srcdir/configure \
  --config-cache \
  --with-pydebug \
  --enable-slower-safety \
  --with-openssl="$OPENSSL_DIR"

# Build CPython out-of-tree
make -j4

# Display build info
make pythoninfo

# Check compiler warnings
make check-warnings

# Remount sources writable for tests (simulated by ensuring write permissions)
chmod -R u+w "$CPYTHON_RO_SRCDIR"

# Run tests
make test