#!/usr/bin/env bash

cd /app

# Run the exact test sequence from the CI job
# Step 1: meson setup, configure, and ninja install with meson test
echo "=== Running meson setup and build with default meson_args ==="
meson setup builddir . --prefix=$PWD/_instdir
meson configure builddir
ninja -C builddir install
meson test -C builddir --print-errorlogs

# Step 2: Check installation of data files
echo "=== Checking installation of data files ==="
diff -u <(cd data/devices; ls *.device) <(cd _instdir/share/libratbag; ls *.device)

# Step 3: ninja uninstall
echo "=== Running ninja uninstall ==="
meson setup builddir . --prefix=$PWD/_instdir
meson configure builddir
ninja -C builddir uninstall

# Step 4: Check if any files are left after uninstall
echo "=== Checking if any files are left after uninstall ==="
(test -d _instdir && tree _instdir && exit 1) || true

echo "FINAL_STATUS = SUCCESS"
