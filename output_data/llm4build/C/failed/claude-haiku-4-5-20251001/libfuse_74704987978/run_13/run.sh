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
export LDFLAGS="-fuse-ld=lld"

# Create Meson native file to explicitly configure the linker
# Note: We pass sanitizer flags in both c_args/cpp_args and link_args
# so that the linker (lld) receives them and can properly handle them
mkdir -p /tmp/meson
cat > /tmp/meson/native.ini << 'EOF'
[binaries]
c = 'clang'
cpp = 'clang++'

[properties]
c_args = ['-fsanitize=address,undefined']
cpp_args = ['-fsanitize=address,undefined']
c_link_args = ['-fuse-ld=lld', '-fsanitize=address,undefined']
cpp_link_args = ['-fuse-ld=lld', '-fsanitize=address,undefined']
EOF

export MESON_NATIVE_FILE=/tmp/meson/native.ini

# Install Ubuntu dependencies (full)
./.github/workflows/install-ubuntu-dependencies.sh --full

# Run CI build
test/ci-build.sh