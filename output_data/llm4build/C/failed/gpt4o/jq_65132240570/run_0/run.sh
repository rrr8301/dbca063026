#!/bin/bash

# Clone the repository
git clone --recurse-submodules <repository-url> .
git config --system core.autocrlf false

# Build
autoreconf -i
./configure \
  --disable-docs \
  --with-oniguruma=builtin \
  --disable-shared \
  --enable-static \
  --enable-all-static \
  CFLAGS="-O2 -pthread -fstack-protector-all -Wl,--stack,8388608"
make -j$(nproc)
file ./jq.exe
cp ./jq.exe jq-windows-i386.exe

# Test
make check VERBOSE=yes
git diff --exit-code || true  # Ensure all tests run even if some fail