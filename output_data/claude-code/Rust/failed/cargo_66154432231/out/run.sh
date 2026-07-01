#!/usr/bin/env bash

export PATH=$HOME/.cargo/bin:$PATH

export CARGO_PROFILE_DEV_DEBUG=1
export CARGO_PROFILE_TEST_DEBUG=1
export CARGO_INCREMENTAL=0
export CARGO_PUBLIC_NETWORK_TESTS=1

cd /app

echo "=== Running cargo test -p cargo ==="
cargo test -p cargo || true

echo "=== Clear intermediate test output ==="
bash ci/clean-test-output.sh || true

echo "=== Running gitoxide tests ==="
export __CARGO_USE_GITOXIDE_INSTEAD_OF_GIT2=1
cargo test -p cargo git || true

echo "=== Clear test output ==="
bash ci/clean-test-output.sh || true

echo "=== Check operability of rustc invocation with argfile ==="
export __CARGO_TEST_FORCE_ARGFILE=1
cargo test -p cargo --test testsuite -- fix:: || true

echo "=== Running workspace tests ==="
cargo test --workspace --exclude cargo --exclude benchsuite --exclude resolver-tests || true

echo "=== Check benchmarks ==="
cargo test -p benchsuite --all-targets -- cargo || true
cargo check -p capture || true

echo "=== Clear benchmark output ==="
bash ci/clean-test-output.sh || true

echo "=== Fetch smoke test ==="
bash ci/fetch-smoke-test.sh || true

echo "FINAL_STATUS = SUCCESS"
