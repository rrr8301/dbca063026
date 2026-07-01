#!/bin/bash

set -e

# Print Rust version info
echo "=== Rust Version ==="
rustc --version --verbose
cargo --version

# Patch Cargo.toml to use nightly extension API
echo "=== Patching Cargo.toml ==="
.github/other/patch-prebuilt.sh nightly

# Compile tests
echo "=== Compiling Tests ==="
cargo test $TEST_FEATURES --no-run

# Run tests (continue even if some fail to ensure all tests are executed)
echo "=== Running Tests ==="
cargo test $TEST_FEATURES || TEST_FAILED=1

# Exit with failure if tests failed
if [ "${TEST_FAILED}" = "1" ]; then
    exit 1
fi

exit 0