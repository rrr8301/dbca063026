#!/bin/bash
set -e

# Activate Rust environment
export PATH="/root/.cargo/bin:${PATH}"

# Ensure we're in the workspace directory
cd /workspace

# Run the test suite using just
just test-all