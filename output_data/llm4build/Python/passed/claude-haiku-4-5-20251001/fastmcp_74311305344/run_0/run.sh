#!/bin/bash
set -e

# Enable error handling: continue on test failures but track exit code
TEST_EXIT_CODE=0

# Install dependencies using uv with locked resolution
echo "Installing dependencies with uv..."
uv sync --locked

# Run unit tests
echo "Running unit tests..."
if ! uv run --no-sync pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "not integration and not client_process and not conformance" \
  --numprocesses auto \
  --maxprocesses 4 \
  --dist worksteal \
  tests; then
  TEST_EXIT_CODE=1
fi

# Run client_process tests
echo "Running client_process tests..."
if ! uv run --no-sync pytest \
  --inline-snapshot=disable \
  --timeout=5 \
  --durations=50 \
  -m "client_process" \
  -x \
  tests; then
  TEST_EXIT_CODE=1
fi

# Exit with appropriate code
exit $TEST_EXIT_CODE