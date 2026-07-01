#!/usr/bin/env bash
set -e

cd /app

echo "Running cargo test -p cargo..."
cargo test -p cargo

echo "Clearing intermediate test output..."
bash ci/clean-test-output.sh

echo "Running gitoxide tests (all git-related tests)..."
__CARGO_USE_GITOXIDE_INSTEAD_OF_GIT2=1 cargo test -p cargo git

echo "Clearing test output..."
bash ci/clean-test-output.sh

echo "Check operability of rustc invocation with argfile..."
__CARGO_TEST_FORCE_ARGFILE=1 cargo test -p cargo --test testsuite -- fix::

echo "Running workspace tests..."
cargo test --workspace --exclude cargo --exclude benchsuite --exclude resolver-tests

echo "Check benchmarks..."
cargo test -p benchsuite --all-targets -- cargo
cargo check -p capture

echo "Clearing benchmark output..."
bash ci/clean-test-output.sh

echo "Running fetch smoke test..."
bash ci/fetch-smoke-test.sh

echo "FINAL_STATUS = SUCCESS"
