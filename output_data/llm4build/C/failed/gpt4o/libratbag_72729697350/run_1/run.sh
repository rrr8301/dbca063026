#!/bin/bash

# Activate any necessary environments (none specified)

# Install project dependencies (none specified beyond pip packages)

# Run meson build and test
meson setup builddir --prefix=$PWD/_instdir
meson configure builddir
ninja -C builddir install
meson test -C builddir --print-errorlogs