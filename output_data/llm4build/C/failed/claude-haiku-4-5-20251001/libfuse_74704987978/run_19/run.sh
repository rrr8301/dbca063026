#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Set environment variable to allow pip to install packages system-wide
export PIP_BREAK_SYSTEM_PACKAGES=1

# Configure to use clang compiler with lld linker
# When using sanitizers (address,undefined), we must use lld as the linker
# because ld.bfd does not support sanitizer instrumentation arguments.
# lld properly handles all sanitizer flags passed by clang.
export CC=clang
export CXX=clang++

# Create Meson native file to explicitly configure the compiler and linker
# Sanitizer flags are passed only to the compiler (c_args, cpp_args).
# The -fuse-ld=lld flag tells the compiler to use lld as the linker.
# We do NOT pass sanitizer flags in link_args because the linker doesn't understand them.
mkdir -p /tmp/meson
cat > /tmp/meson/native.ini << 'EOF'
[binaries]
c = 'clang'
cpp = 'clang++'

[properties]
c_args = ['-fsanitize=address,undefined', '-fuse-ld=lld']
cpp_args = ['-fsanitize=address,undefined', '-fuse-ld=lld']
c_link_args = ['-fuse-ld=lld']
cpp_link_args = ['-fuse-ld=lld']
EOF

export MESON_NATIVE_FILE=/tmp/meson/native.ini

# Install Ubuntu dependencies (full)
./.github/workflows/install-ubuntu-dependencies.sh --full

# Run CI build
test/ci-build.sh