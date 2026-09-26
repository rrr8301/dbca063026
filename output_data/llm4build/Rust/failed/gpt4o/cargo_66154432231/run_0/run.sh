#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Install project dependencies
cargo update

# Run tests
set +e  # Continue on errors
cargo test -p cargo
cargo test -p cargo git
CARGO_TEST_FORCE_ARGFILE=1 cargo test -p cargo --test testsuite -- fix::
cargo test --workspace --exclude cargo --exclude benchsuite --exclude resolver-tests
cargo test -p benchsuite --all-targets -- cargo
cargo check -p capture

# Fetch smoke test
ci/fetch-smoke-test.sh

# Ensure all test cases are executed
set -e