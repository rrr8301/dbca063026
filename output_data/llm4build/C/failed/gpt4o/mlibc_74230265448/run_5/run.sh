#!/bin/bash

set -e

# Set environment variables
DEBIAN_ARCH=i386
DEBIAN_MULTILIB=i686

# Prepare directories
mkdir -p src/mlibc build

# Download libgcc binaries
wget -O /tmp/libgcc-i686.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-i686.a

# Checkout source code
git clone --depth 1 https://github.com/managarm/mlibc.git src/mlibc/

# Prepare src/
cp src/mlibc/ci/bootstrap.yml src/
touch src/mlibc/checkedout.xbstrap

# Prepare build/
cat > build/bootstrap-site.yml << EOF
define_options:
  arch: x86
  compiler: gcc
  multilib-path: "/usr/$DEBIAN_MULTILIB-linux-gnu"
EOF

# Initialize xbstrap
cd build
xbstrap init ../src

# Build mlibc
xbstrap install mlibc || { echo "Build failed"; exit 1; }

# Test mlibc
meson test -v -C pkg-builds/mlibc || { echo "Tests failed"; exit 1; }