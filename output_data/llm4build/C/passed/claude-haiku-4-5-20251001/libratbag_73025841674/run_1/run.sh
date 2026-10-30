#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Build with meson
echo "=== Setting up meson ==="
meson setup builddir . --prefix=$PWD/_instdir

echo "=== Configuring meson ==="
meson configure builddir

echo "=== Building with ninja ==="
ninja -C builddir install

echo "=== Running meson tests ==="
meson test -C builddir --print-errorlogs || true

echo "=== Checking installation of data files ==="
diff -u <(cd data/devices; ls *.device) <(cd _instdir/share/libratbag; ls *.device) || true

echo "=== Running ninja uninstall ==="
ninja -C builddir uninstall

echo "=== Checking if any files are left after uninstall ==="
if test -d _instdir; then
    echo "ERROR: Files remain after uninstall:"
    tree _instdir
    exit 1
else
    echo "SUCCESS: All files cleaned up after uninstall"
    exit 0
fi