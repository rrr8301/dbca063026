#!/bin/bash

# Clone repository with submodules
git submodule update --init

# Build the project
autoreconf -i
./configure --host=x86_64-linux-gnu --disable-docs --with-oniguruma=builtin --enable-static --enable-all-static CFLAGS="-O2 -pthread -fstack-protector-all"
make -j"$(nproc)"

# Test the project
make check VERBOSE=yes || true
git diff --exit-code || true