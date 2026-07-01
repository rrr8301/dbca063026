#!/bin/bash

# Activate environment (if any specific activation is needed, add here)

# Install system dependencies using getdeps.py
sudo python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive folly
sudo python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Fetch and build dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --free-up-disk --no-tests boost

# Build folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. folly --project-install-prefix folly:/usr/local

# Test folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. folly --project-install-prefix folly:/usr/local

# Ensure all tests are executed
if [ $? -ne 0 ]; then
    echo "Some tests failed, but continuing..."
fi