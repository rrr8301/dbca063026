#!/bin/bash

# Set environment variables
export DEBIAN_ARCH=amd64
export DEBIAN_MULTILIB=x86_64

# Prepare directories
mkdir -p src/mlibc build

# Download libgcc binaries
wget -O /tmp/libgcc-x86_64.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-x86_64.a

# Checkout source code
git clone --depth=1 https://github.com/managarm/mlibc.git src/mlibc

# Prepare src/
cp src/mlibc/ci/bootstrap.yml src/
touch src/mlibc/checkedout.xbstrap

# Prepare build/
cat > build/bootstrap-site.yml << EOF
define_options:
  arch: x86_64
  compiler: gcc
  multilib-path: "/usr/$DEBIAN_MULTILIB-linux-gnu"
EOF

# Initialize and build
cd build
xbstrap init ../src
xbstrap install mlibc

# Test mlibc
meson test -v -C pkg-builds/mlibc