#!/usr/bin/env bash
set -e

. $HOME/.cargo/env

cd /app

echo "Building buck2 binary (debug)..."
mkdir -p /tmp/artifacts
cargo build --bin=buck2 -Z unstable-options --artifact-dir=/tmp/artifacts

echo "Running test.py..."
python3 test.py --ci --git --buck2=/tmp/artifacts/buck2

FINAL_STATUS = SUCCESS
