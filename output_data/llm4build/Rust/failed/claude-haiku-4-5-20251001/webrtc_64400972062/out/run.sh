#!/bin/bash
set -e

# Clone the repository with recursive submodules
# (In this case, the repo is already copied, but we ensure submodules are initialized)
git submodule update --init --recursive

# Run cargo tests with verbose output
cargo test --verbose