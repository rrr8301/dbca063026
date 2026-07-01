#!/bin/bash

# Activate Rust environment
source $HOME/.cargo/env

# Build buck2 binary (debug)
mkdir -p $RUNNER_TEMP/artifacts
cargo build --bin=buck2 -Z unstable-options --artifact-dir=$RUNNER_TEMP/artifacts

# Run test.py
python3 test.py --ci --git --buck2=$RUNNER_TEMP/artifacts/buck2