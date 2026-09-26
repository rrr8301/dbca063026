#!/bin/bash
set -euo pipefail

# Ensure Rust toolchain is properly initialized
source "$HOME/.cargo/env"

# Install nextest
echo "Installing nextest@0.9.98..."
cargo install nextest@0.9.98

# Install gdb (if not already installed)
apt-get update && apt-get install -y gdb || true

# Run tests in a loop for 15 minutes
echo "Starting flaky test detection loop..."
SECONDS=0
deadline=$((15 * 60))
iteration=1
while [ $SECONDS -lt $deadline ]; do
  echo "=== Iteration $iteration (elapsed ${SECONDS}s) ==="
  if ! cargo nextest run --workspace --lib --all-features --all-targets --profile ci; then
    echo "Tests failed during iteration $iteration"
    exit 1
  fi
  iteration=$((iteration + 1))
done
completed=$((iteration - 1))
echo "Completed $completed iteration(s) in ${SECONDS}s without failures"