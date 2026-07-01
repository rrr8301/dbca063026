#!/bin/bash

# Activate the virtual environment
source /opt/venv/bin/activate

# Run meson build and test
meson setup builddir --prefix=$PWD/_instdir
meson configure builddir
ninja -C builddir install
meson test -C builddir --print-errorlogs