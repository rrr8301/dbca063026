#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Dump Environment
ci/dump-environment.sh

# Run tests
cargo test -p cargo
ci/clean-test-output.sh

# Run gitoxide tests
__CARGO_USE_GITOXIDE_INSTEAD_OF_GIT2=1 cargo test -p cargo git
ci/clean-test-output.sh

# Check operability of rustc invocation with argfile
__CARGO_TEST_FORCE_ARGFILE=1 cargo test -p cargo --test testsuite -- fix::

# Run workspace tests excluding certain packages
cargo test --workspace --exclude cargo --exclude benchsuite --exclude resolver-tests

# Check benchmarks
cargo test -p benchsuite --all-targets -- cargo
cargo check -p capture
ci/clean-test-output.sh

# Fetch smoke test
ci/fetch-smoke-test.sh