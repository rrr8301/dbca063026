#!/bin/bash

# Clone the repository
git clone --recurse-submodules https://github.com/stedolan/jq.git /app/jq  # Ensure cloning into a subdirectory
cd /app/jq
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

# Check if the build was successful
if [ ! -f ./jq ]; then
  echo "Build failed: jq executable not found."
  exit 1
fi

# Test
make check VERBOSE=yes  # Ensure all tests run
git diff --exit-code  # Ensure all tests run