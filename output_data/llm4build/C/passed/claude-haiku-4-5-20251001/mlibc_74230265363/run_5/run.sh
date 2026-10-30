#!/bin/bash
set -e

# Download libgcc binaries
wget -O /tmp/libgcc-x86_64.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-x86_64.a

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

# Build mlibc with verbose output for debugging
cd build/
xbstrap install -v mlibc
cd ..

# Test mlibc
export LANG="en_US.utf8"
meson test -v -C build/pkg-builds/mlibc