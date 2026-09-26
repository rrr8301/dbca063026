#!/bin/bash

# Activate Python environment
python3 -m venv venv
source venv/bin/activate

# Install project dependencies
pip install --upgrade pip

# Run meson build
meson setup builddir
ninja -C builddir

# Run meson test
meson test -C builddir