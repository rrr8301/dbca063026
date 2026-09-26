#!/bin/bash
set -e

# Download libgcc binaries
mkdir -p /tmp/libgcc
wget -O /tmp/libgcc/libgcc-x86_64.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-x86_64.a

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

# Build mlibc with verbose output to see compilation details
cd build/
xbstrap -v install mlibc 2>&1 | tee build.log || {
    echo "Build failed. Checking for build issues..."
    tail -100 build.log
    exit 1
}
cd ..

# Test mlibc - run meson test in the correct build directory
export LANG="en_US.utf8"
meson test -v -C build/pkg-builds/mlibc/build