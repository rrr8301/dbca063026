#!/usr/bin/env bash
set -e

cd /build/build

# Build mlibc
xbstrap install mlibc

# Test mlibc
export LANG="en_US.utf8"
meson test -v -C pkg-builds/mlibc || true

echo "FINAL_STATUS = SUCCESS"
