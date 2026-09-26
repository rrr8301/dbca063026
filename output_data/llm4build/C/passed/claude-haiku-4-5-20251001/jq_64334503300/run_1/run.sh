#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Build
echo "=== Running autoreconf ==="
autoreconf -i

echo "=== Running configure ==="
./configure \
  --host=x86_64-linux-gnu \
  --disable-docs \
  --with-oniguruma=builtin \
  --enable-static \
  --enable-all-static \
  CFLAGS="-O2 -pthread -fstack-protector-all"

echo "=== Running make ==="
make -j"$(nproc)"

echo "=== Checking binary ==="
file ./jq

echo "=== Copying artifact ==="
cp ./jq jq-linux-amd64

# Test
echo "=== Running tests ==="
make check VERBOSE=yes

echo "=== Verifying no git diff ==="
git diff --exit-code

echo "=== Build and tests completed successfully ==="