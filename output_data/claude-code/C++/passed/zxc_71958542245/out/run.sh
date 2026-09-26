#!/usr/bin/env bash

set -e

echo "===== Running Test (native) ====="
cd /app/build
ctest -C Release --output-on-failure

echo "===== Running Test CLI ====="
cd /app

BUILD_DIR="build"
if [ -f "$BUILD_DIR/Release/zxc" ]; then
  ZXC_BIN="$BUILD_DIR/Release/zxc"
elif [ -f "$BUILD_DIR/zxc" ]; then
  ZXC_BIN="$BUILD_DIR/zxc"
else
  echo "Binary not found for CLI test!"
  find "$BUILD_DIR" -name "zxc"
  exit 1
fi

echo "Testing with binary: $ZXC_BIN"
chmod +x tests/test_cli.sh
./tests/test_cli.sh "$ZXC_BIN"

echo "FINAL_STATUS = SUCCESS"
