#!/bin/bash

# Update system package info
sudo apt-get update

# Install system dependencies using getdeps.py
sudo python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle
sudo python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Ensure OpenSSL is installed
sudo apt-get install -y libssl-dev

# Query paths
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. wangle

# Fetch dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz

# Build wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. wangle _artifacts/linux --project-install-prefix wangle:/usr/local --final-install-prefix /usr/local

# Test wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local