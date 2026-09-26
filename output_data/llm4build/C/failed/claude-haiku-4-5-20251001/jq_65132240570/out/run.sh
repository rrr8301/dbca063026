#!/bin/bash
set -e

autoreconf -i
./configure \
  --disable-docs \
  --with-oniguruma=builtin \
  --disable-shared \
  --enable-static \
  --enable-all-static \
  CFLAGS="-O2 -pthread -fstack-protector-all" \
  LDFLAGS="-s"
make -j$(nproc)
make check VERBOSE=yes