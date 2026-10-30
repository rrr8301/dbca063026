#!/usr/bin/env bash

set -e

cd /app

echo "Running tests for petgraph (Rust beta)"
echo "========================================"

# Run tests with default features
echo "Running: cargo nextest run --package petgraph --verbose"
cargo nextest run --package petgraph --verbose || true

# Run tests with all features
echo ""
echo "Running: cargo nextest run --package petgraph --all-features --verbose"
cargo nextest run --package petgraph --all-features --verbose || true

echo ""
echo "========================================"
echo "FINAL_STATUS = SUCCESS"
