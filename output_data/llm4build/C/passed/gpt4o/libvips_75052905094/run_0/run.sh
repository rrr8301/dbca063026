#!/bin/bash

# Set environment variables
export CC=gcc-14
export CXX=g++-14
export LD=ld
export CPPFLAGS="-Wall"

# Configure libvips
meson setup build \
  -Ddebug=true \
  -Ddeprecated=false \
  -Dmagick=disabled \
  -Ddocs=true \
  -Dintrospection=enabled \
  -Db_sanitize=none \
  -Db_lundef=true || (cat build/meson-logs/meson-log.txt && exit 1)

# Build libvips
meson compile -C build

# Check libvips
meson test -C build --timeout-multiplier=1 || (cat build/meson-logs/testlog.txt && exit 1)

# Install libvips
sudo meson install -C build

# Rebuild the shared library cache
sudo ldconfig

# Run test suite
export VIPS_LEAK=1
python3 -m pytest -sv --log-cli-level=WARNING test/test-suite