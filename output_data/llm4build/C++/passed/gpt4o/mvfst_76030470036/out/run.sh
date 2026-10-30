#!/bin/bash

# Install project dependencies
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive mvfst
sudo --preserve-env=http_proxy python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Fetch and build dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz

# Build dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --no-tests folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --no-tests fizz

# Build mvfst
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --build-type RelWithDebInfo --src-dir=. mvfst --project-install-prefix mvfst:/usr/local

# Test mvfst
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --build-type RelWithDebInfo --src-dir=. mvfst --project-install-prefix mvfst:/usr/local