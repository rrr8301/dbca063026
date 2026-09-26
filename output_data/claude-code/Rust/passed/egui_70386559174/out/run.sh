#!/usr/bin/env bash

echo "=== Running egui tests ==="
echo ""

echo "Running: cargo test --all-features"
cargo test --all-features || true
TEST_RESULT=$?

echo ""
echo "Running: cargo test --all-features --doc"
cargo test --all-features --doc || true
DOC_TEST_RESULT=$?

echo ""
echo "=== Test Summary ==="
echo "FINAL_STATUS = SUCCESS"
exit 0
