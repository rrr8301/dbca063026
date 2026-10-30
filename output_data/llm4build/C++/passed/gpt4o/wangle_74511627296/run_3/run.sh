#!/bin/bash

# Activate environment if needed (placeholder)

# Install project dependencies using getdeps.py
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Fetch dependencies
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests boost
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fast_float
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fmt
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests glog
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests googletest
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests liboqs
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests libunwind
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests xz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests folly
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests fizz
python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests openssl

# Build wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. wangle --project-install-prefix wangle:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. wangle _artifacts/linux --project-install-prefix wangle:/usr/local --final-install-prefix /usr/local

# Test wangle
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. wangle --project-install-prefix wangle:/usr/local