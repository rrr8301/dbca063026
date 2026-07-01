#!/usr/bin/env bash

cd /app/_build

# Build
echo "=== Building ==="
make -j $JOBS || { echo "Build failed"; exit 1; }

# Run Tests
echo "=== Running Tests ==="
make -j $JOBS check || {
  err="$?"
  echo "make exited with code $err" >&2
  echo "Test suite logs:" >&2
  find . -name 'test-suite.log' -exec cat '{}' ';' >&2
}

# Run distcheck (even if tests failed, as per the workflow)
echo "=== Running distcheck ==="
make -j $JOBS distcheck DISTCHECK_CONFIGURE_FLAGS="$CONFIGURE_FLAGS" || {
  echo "distcheck failed"
}

echo "FINAL_STATUS = SUCCESS"
