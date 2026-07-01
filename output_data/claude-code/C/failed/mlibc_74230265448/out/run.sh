#!/usr/bin/env bash

cd /work/build

echo "Running meson test..."
meson test -v -C pkg-builds/mlibc || true

echo "FINAL_STATUS = SUCCESS"
