#!/bin/bash

# Activate environment (if any specific activation is needed, otherwise skip)
# Example: source /path/to/venv/bin/activate

# Install project dependencies (if any)
# Example: pip install -r requirements.txt

# Run Meson build
meson setup builddir
meson compile -C builddir

# Run Meson tests
meson test -C builddir --print-errorlogs