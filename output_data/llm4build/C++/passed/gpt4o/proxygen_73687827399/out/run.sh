#!/bin/bash

# Update system package info
sudo --preserve-env=http_proxy apt-get update

# Install system dependencies using getdeps.py
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive proxygen
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. proxygen

# Fetch dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests c-ares
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests gperf
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests mvfst
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests wangle

# Build proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. proxygen _artifacts/linux --project-install-prefix proxygen:/usr/local --final-install-prefix /usr/local

# Test proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. proxygen --project-install-prefix proxygen:/usr/local