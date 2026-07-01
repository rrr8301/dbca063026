#!/bin/bash

# Activate the virtual environment
source /opt/venv/bin/activate

# Generate ./configure if it doesn't exist
if [ ! -f ./configure ]; then
    ./autogen.sh
fi

# Fast configure
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
    --prefix=$PWD/install

# Fast build, install, and clean
make -j$(nproc)
make -j$(nproc) install
make -j$(nproc) distclean

# Minimal install test
cd install/bin
./re2c --version
cd -

# Get build directory
BUILD_DIR="$(pwd)/.build/linux-gcc-ootree-full"
mkdir -p "$BUILD_DIR"

# Full configure
cd "$BUILD_DIR"
../configure \
    --prefix=$PWD/full-install \
    --enable-libs \
    --enable-parsers \
    --enable-lexers \
    --enable-docs \
    --enable-debug \
    RE2C_FOR_BUILD=../install/bin/re2c

# Full build
find ../src -name '*.re' | xargs touch
make -j$(nproc)

# Run main test suite
bash -c "ulimit -s 256; make check -j$(nproc)"

# Run skeleton tests
if [ -f ../run_tests.py ]; then
    python3 ../run_tests.py --skeleton
else
    echo "Warning: run_tests.py not found, skipping skeleton tests."
fi

# Full install
make -j$(nproc) install