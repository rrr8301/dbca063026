#!/usr/bin/env bash

set -e

# Replicate the exact workflow steps for clang-22 job

echo "=== Starting FunctionalPlus clang-22 CI job ==="

# Step 1: Setup (from ci_setup_linux.sh)
echo "Step 1: Running setup..."
/app/script/ci_setup_linux.sh

# Step 2: Setup libc++ (already set in Dockerfile, but ensuring it's available)
echo "Step 2: libc++ is configured with CXXFLAGS=-stdlib=libc++"

# Step 3: Build and Test
echo "Step 3: Running build and tests..."
/app/script/ci.sh run_tests

echo "=== All tests completed ==="
echo "FINAL_STATUS = SUCCESS"
