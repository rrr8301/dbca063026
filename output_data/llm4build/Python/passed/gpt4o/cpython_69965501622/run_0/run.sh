#!/bin/bash

# Set environment variables for OpenSSL
export MULTISSL_DIR=$(pwd)/multissl
export OPENSSL_DIR=$(pwd)/multissl/openssl/3.5.5
export LD_LIBRARY_PATH=$(pwd)/multissl/openssl/3.5.5/lib

# Setup directory envs for out-of-tree builds
export CPYTHON_RO_SRCDIR=$(realpath -m "$(pwd)"/../cpython-ro-srcdir)
export CPYTHON_BUILDDIR=$(realpath -m "$(pwd)"/../cpython-builddir)

# Create directories for read-only out-of-tree builds
mkdir -p "$CPYTHON_RO_SRCDIR" "$CPYTHON_BUILDDIR"

# Bind mount sources read-only
sudo mount --bind -o ro "$(pwd)" "$CPYTHON_RO_SRCDIR"

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

# Remount sources writable for tests
sudo mount "$CPYTHON_RO_SRCDIR" -oremount,rw

# Run tests
make test