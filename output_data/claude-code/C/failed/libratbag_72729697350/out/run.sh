#!/usr/bin/env bash
set -e

cd /app

echo "=== Setting up meson ==="
meson setup builddir . --prefix=$PWD/_instdir

echo "=== Configuring meson ==="
meson configure builddir

echo "=== Building with ninja ==="
ninja -C builddir

echo "=== Running meson tests ==="
meson test -C builddir --print-errorlogs || true

echo "=== Installing with ninja ==="
ninja -C builddir install

echo "=== Checking installation of data files ==="
diff -u <(cd data/devices; ls *.device) <(cd _instdir/share/libratbag; ls *.device)

echo "=== Running ninja uninstall ==="
ninja -C builddir uninstall

echo "=== Checking if any files are left after uninstall ==="
if test -d _instdir && tree _instdir; then
    echo "ERROR: Files left after uninstall"
    exit 1
else
    echo "OK: No files left after uninstall"
fi

echo "FINAL_STATUS = SUCCESS"
