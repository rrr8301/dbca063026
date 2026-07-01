#!/usr/bin/env bash
set -e

mkdir -p /tmp/artifacts

echo "Building buck2 binary (debug)..."
cargo build --bin=buck2 -Z unstable-options --artifact-dir=/tmp/artifacts

echo "Running tests..."
python3 test.py --ci --git --buck2=/tmp/artifacts/buck2

echo "FINAL_STATUS = SUCCESS"
