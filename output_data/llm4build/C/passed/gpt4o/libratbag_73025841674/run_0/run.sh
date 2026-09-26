#!/bin/bash

# Activate any necessary environments (none specified)

# Install project dependencies (none specified beyond global packages)

# Run meson build and test
meson setup builddir --prefix=$PWD/_instdir
meson configure builddir
ninja -C builddir install
meson test -C builddir --print-errorlogs

# Check installation of data files
diff -u <(cd data/devices; ls *.device) <(cd _instdir/share/libratbag; ls *.device)

# Uninstall and verify cleanup
ninja -C builddir uninstall
(test -d _instdir && tree _instdir && exit 1) || exit 0