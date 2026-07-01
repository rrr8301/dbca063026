#!/usr/bin/env bash
set -e

cargo test --workspace --all-features

echo "FINAL_STATUS = SUCCESS"
