#!/usr/bin/env bash
set -e

cd /app
cargo test
echo "FINAL_STATUS = SUCCESS"
