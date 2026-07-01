#!/bin/bash
set -e

# Configure libvips
echo "Configuring libvips..."
meson setup build \
  -Ddebug=true \
  -Ddeprecated=false \
  -Dmagick=disabled \
  -Ddocs=true \
  -Dintrospection=enabled \
  -Db_sanitize=none \
  -Db_lundef=true \
  || (cat build/meson-logs/meson-log.txt && exit 1)

# Build libvips
echo "Building libvips..."
meson compile -C build

# Run libvips tests
echo "Running libvips test suite..."
meson test -C build --timeout-multiplier=1 \
  || (cat build/meson-logs/testlog.txt && exit 1)

# Install libvips
echo "Installing libvips..."
sudo meson install -C build

# Rebuild the shared library cache
echo "Rebuilding shared library cache..."
sudo ldconfig

# Install pyvips with test dependencies
echo "Installing pyvips..."
pip3 install pyvips[test] --break-system-packages

# Run pyvips test suite
echo "Running pyvips test suite..."
export VIPS_LEAK=1
python3 -m pytest -sv --log-cli-level=WARNING test/test-suite