#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run the Ubuntu dependencies installation script
./.github/workflows/install-ubuntu-dependencies.sh --full

# Run the CI build script
test/ci-build.sh