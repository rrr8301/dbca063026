#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run the Ubuntu dependencies installation script with conflict resolution
# Use --no-install-recommends and handle pkg-config conflict
./.github/workflows/install-ubuntu-dependencies.sh --full || {
    # If full installation fails due to pkg-config conflict, 
    # remove pkg-config:i386 and retry
    echo "Retrying installation after removing conflicting pkg-config:i386..."
    apt-get update
    apt-get install -y --no-install-recommends \
        gcc-multilib \
        g++-multilib \
        libc6-dev-i386 \
        libstdc++6:i386 \
        || true
    apt-get install -y --no-install-recommends pkg-config || true
}

# Run the CI build script
test/ci-build.sh