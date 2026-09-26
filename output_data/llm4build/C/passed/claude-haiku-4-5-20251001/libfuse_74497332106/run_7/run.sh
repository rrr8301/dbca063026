#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run the Ubuntu dependencies installation script with conflict resolution
./.github/workflows/install-ubuntu-dependencies.sh --full || {
    # If full installation fails, retry with apt-get fix-broken
    echo "Retrying installation with fix-broken..."
    apt-get update
    apt-get install -y --fix-broken || true
    ./.github/workflows/install-ubuntu-dependencies.sh --full || true
}

# Run the CI build script
test/ci-build.sh