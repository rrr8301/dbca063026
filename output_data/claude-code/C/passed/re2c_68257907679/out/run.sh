#!/usr/bin/env bash
set -x

cd /app

# Generate ./configure
./autogen.sh

# Fast Configure
./configure \
    --disable-dlang \
    --disable-golang \
    --disable-haskell \
    --disable-java \
    --disable-js \
    --disable-ocaml \
    --disable-python \
    --disable-rust \
    --disable-swift \
    --disable-vlang \
    --disable-zig \
    --prefix=/app/install

# Fast Build
make -j$(nproc)

# Fast Install
make -j$(nproc) install

# Fast Clean
make -j$(nproc) distclean

# Minimal Install Test
/app/install/bin/re2c --version

# Get build dir (ootree build)
BUILD_DIR="/app/.build/linux-gcc-ootree-full"
mkdir -p "$BUILD_DIR"

# Full Configure
cd "$BUILD_DIR"
/app/configure \
    --prefix="$BUILD_DIR/full-install" \
    --enable-libs \
    --enable-parsers \
    --enable-lexers \
    --enable-docs \
    --enable-debug \
    RE2C_FOR_BUILD=/app/install/bin/re2c

# Full Build
find /app/src -name '*.re' | xargs touch
make -j$(nproc)

# Run Main Test Suite
bash -c "ulimit -s 256; make check -j$(nproc)"

# Run Skeleton Tests
python3 run_tests.py --skeleton

# Full Install
make -j$(nproc) install

echo "FINAL_STATUS = SUCCESS"
