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
if [ -d "build/pkg-builds/mlibc/build" ]; then
    meson test -v -C build/pkg-builds/mlibc/build 2>&1 | tee test.log || {
        echo "Tests completed with status code $?"
        tail -50 test.log
    }
elif [ -d "build/pkg-builds/mlibc" ]; then
    echo "Found mlibc build directory at build/pkg-builds/mlibc"
    echo "Attempting to run tests..."
    meson test -v -C build/pkg-builds/mlibc 2>&1 | tee test.log || {
        echo "Tests completed with status code $?"
        tail -50 test.log
    }
else
    echo "Warning: mlibc build directory not found at expected location"
    echo "Available directories:"
    find build -type d -name "mlibc" 2>/dev/null || true
    find build -type d -name "build" 2>/dev/null || true
    exit 1
fi