#!/usr/bin/env bash

set -e

cd /app

# Step 1: Test (main tests)
echo "=== Running: cargo test --features internal ==="
cargo test --features internal 2>&1 || TEST_FAILED=1

# Step 2: Test clippy_lints
echo "=== Running: cargo test (clippy_lints) ==="
(cd clippy_lints && cargo test 2>&1) || TEST_FAILED=1

# Step 3: Test clippy_utils
echo "=== Running: cargo test (clippy_utils) ==="
(cd clippy_utils && cargo test 2>&1) || TEST_FAILED=1

# Step 4: Test rustc_tools_util
echo "=== Running: cargo test (rustc_tools_util) ==="
(cd rustc_tools_util && cargo test 2>&1) || TEST_FAILED=1

# Step 5: Test clippy_dev
echo "=== Running: cargo test (clippy_dev) ==="
(cd clippy_dev && cargo test 2>&1) || TEST_FAILED=1

# Step 6: Test clippy-driver
echo "=== Running: .github/driver.sh ==="
.github/driver.sh 2>&1 || TEST_FAILED=1

# Final status
if [ -z "$TEST_FAILED" ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi
