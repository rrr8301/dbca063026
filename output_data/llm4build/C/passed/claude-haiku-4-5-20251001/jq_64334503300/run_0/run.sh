#!/bin/bash
set -e

# Set cross-compilation environment variables
export AR=x86_64-linux-gnu-ar
export CHOST=x86_64-linux-gnu
export CC=x86_64-linux-gnu-gcc
export CPP=x86_64-linux-gnu-cpp
export LDFLAGS="-s"
export SUFFIX=linux-amd64

# Initialize git submodules
cd /workspace
git submodule update --init --recursive

# Build
echo "=== Building jq ==="
autoreconf -i
./configure \
  --host=x86_64-linux-gnu \
  --disable-docs \
  --with-oniguruma=builtin \
  --enable-static \
  --enable-all-static \
  CFLAGS="-O2 -pthread -fstack-protector-all"
make -j"$(nproc)"
file ./jq
cp ./jq jq-linux-amd64

# Test
echo "=== Running tests ==="
make check VERBOSE=yes
git diff --exit-code

echo "=== Build and tests completed successfully ==="