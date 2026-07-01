#!/bin/bash

set -e

# Setup environment variables based on architecture
ARCH="x86"
BUILDS="mlibc"
COMPILER="gcc"

case "$ARCH" in
  x86)
    DEBIAN_ARCH=i386
    DEBIAN_MULTILIB=i686
    ;;
  x86_64)
    DEBIAN_ARCH=amd64
    DEBIAN_MULTILIB=x86_64
    ;;
  aarch64)
    DEBIAN_ARCH=arm64
    DEBIAN_MULTILIB=aarch64
    ;;
  loongarch64)
    DEBIAN_ARCH=loong64
    DEBIAN_MULTILIB=loongarch64
    ;;
  *)
    DEBIAN_ARCH=$ARCH
    DEBIAN_MULTILIB=$ARCH
    ;;
esac

export DEBIAN_ARCH
export DEBIAN_MULTILIB

# Install architecture-specific packages
apt-get update
apt-get install -y libc6-dev-$DEBIAN_ARCH-cross

case "$ARCH" in
  x86)
    apt-get install -y gcc-i686-linux-gnu g++-i686-linux-gnu libc6-dev-i386-cross
    ;;
  x86_64)
    apt-get install -y gcc g++
    ;;
  *)
    apt-get install -y gcc-$ARCH-linux-gnu g++-$ARCH-linux-gnu
    ;;
esac

rm -rf /var/lib/apt/lists/*

# Prepare directories
mkdir -p src/mlibc
mkdir -p build

# Get libgcc-binaries
set -e
case "$ARCH" in
  x86)
    wget -O /tmp/libgcc-$ARCH.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-i686.a
    ;;
  *)
    wget -O /tmp/libgcc-$ARCH.a https://github.com/osdev0/libgcc-binaries/releases/latest/download/libgcc-$ARCH.a
    ;;
esac

# Checkout (copy repository to src/mlibc/)
# Copy all files except src/ and build/ directories to avoid circular copy
find . -maxdepth 1 -not -name 'src' -not -name 'build' -not -name 'run.sh' | tail -n +2 | xargs -I {} cp -r {} src/mlibc/

# Prepare src/
cd src/
cp mlibc/ci/bootstrap.yml .
touch mlibc/checkedout.xbstrap
cd ..

# Prepare build/
cd build/
cat > bootstrap-site.yml << EOF
define_options:
  arch: $ARCH
  compiler: $COMPILER
  multilib-path: "/usr/$DEBIAN_MULTILIB-linux-gnu"
EOF
xbstrap init ../src
cd ..

# Build mlibc with proper compiler settings
cd build/
case "$ARCH" in
  x86)
    export CC=i686-linux-gnu-gcc
    export CXX=i686-linux-gnu-g++
    ;;
  x86_64)
    export CC=gcc
    export CXX=g++
    ;;
  *)
    export CC=$ARCH-linux-gnu-gcc
    export CXX=$ARCH-linux-gnu-g++
    ;;
esac

export CFLAGS="-Wno-error -I/usr/$DEBIAN_MULTILIB-linux-gnu/include"
export CXXFLAGS="-Wno-error -I/usr/$DEBIAN_MULTILIB-linux-gnu/include"
export LDFLAGS="-L/usr/$DEBIAN_MULTILIB-linux-gnu/lib"
export PKG_CONFIG_PATH="/usr/$DEBIAN_MULTILIB-linux-gnu/lib/pkgconfig:/usr/lib/pkgconfig"
export CPPFLAGS="-I/usr/$DEBIAN_MULTILIB-linux-gnu/include"

xbstrap install $BUILDS
cd ..

# Test mlibc
cd build/
export LANG="en_US.utf8"
meson test -v -C pkg-builds/$BUILDS
cd ..