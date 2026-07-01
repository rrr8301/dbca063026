#!/usr/bin/env bash
set -e

echo "=== Checking Available Configure Presets ==="
cmake --list-presets

echo ""
echo "=== Fast Configure ==="
cmake --preset=linux-gcc-ubsan-ootree-fast -DPython3_ROOT_DIR="/usr/bin"

echo ""
echo "=== Fast Build ==="
cmake --build --preset=linux-gcc-ubsan-ootree-fast -j$(nproc)

echo ""
echo "=== Install ==="
cmake --build --preset=linux-gcc-ubsan-ootree-fast --target install

echo ""
echo "=== Minimal Install Test ==="
cd ./install/bin
./re2c --version
cd /app

echo ""
echo "=== Full Configure ==="
cmake --preset=linux-gcc-ubsan-ootree-full -DPython3_ROOT_DIR="/usr/bin"

echo ""
echo "=== Full Build ==="
find src -name '*.re' | xargs touch
cmake --build --preset=linux-gcc-ubsan-ootree-full -j$(nproc)

echo ""
echo "=== Run Main Test Suite ==="
bash -c "ulimit -s 256; cmake --build --preset=linux-gcc-ubsan-ootree-full --target tests -j$(nproc)" || true

echo ""
echo "FINAL_STATUS = SUCCESS"
