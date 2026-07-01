#!/bin/bash
set -e

# Ensure we're in the workspace directory
cd /workspace

# Run the crossterm backend tests
cargo xtask test-backend crossterm