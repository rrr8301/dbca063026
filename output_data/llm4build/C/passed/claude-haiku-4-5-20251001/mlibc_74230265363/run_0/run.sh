#!/bin/bash

set -e

# Setup architecture variables
DEBIAN_ARCH=amd64
DEBIAN_MULTILIB=x86_64

export DEBIAN_ARCH
export DEBIAN_MULTILIB

# Prepare directories
mkdir -p src/
mkdir -p src/mlibc/
mkdir -p build/

# Get libgcc-binaries
wget -O /tmp/libgcc-x86_64.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-x86_64.a

# Checkout (copy repo to src/mlibc/)
cp -r . src/mlibc/

# Prepare src/
cd src/
cp mlibc/ci/bootstrap.yml .
touch mlibc/checkedout.xbstrap
cd ..

# Prepare build/
cd build/
cat > bootstrap-site.yml << EOF
define_options:
  arch: x86_64
  compiler: gcc
  multilib-path: "/usr/x86_64-linux-gnu"
EOF
xbstrap init ../src
cd ..

# Build mlibc
cd build/
xbstrap install mlibc
cd ..

# Test mlibc
export LANG="en_US.utf8"
meson test -v -C build/pkg-builds/mlibc