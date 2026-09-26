#!/bin/bash

set -e

# Set environment variables from matrix
export CC=gcc
export CMAKE_GENERATOR=Ninja
export CMAKE_OPTIONS="-DUSE_HTTPS=OpenSSL -DREGEX_BACKEND=builtin -DDEBUG_LEAK_CHECKER=valgrind -DUSE_GSSAPI=ON -DUSE_SSH=libssh2 -DDEBUG_STRICT_ALLOC=ON -DDEBUG_STRICT_OPEN=ON"

# Prepare build directory (if not already present)
mkdir -p /workspace/build

# Setup SSH environment for tests
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# Generate SSH keys if they don't exist
if [ ! -f /root/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
fi

# Build
cd /workspace/build
/workspace/source/ci/build.sh

# Test
/workspace/source/ci/test.sh

echo "Build and test completed successfully"