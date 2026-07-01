#!/bin/bash

# Activate environment variables if needed (none specified)

# Install project dependencies (none specified)

# Run sysctl commands
sysctl vm.legacy_va_layout
sysctl kernel.randomize_va_space
sysctl vm.mmap_rnd_bits
sysctl -w vm.mmap_rnd_bits=28

# Configure the build with CMake
cmake -S. -Bcmake-build -GNinja \
    -DPOCO_SANITIZEFLAGS="-fsanitize=address" \
    -DENABLE_TRACE=ON \
    -DPOCO_MINIMAL_BUILD=ON -DENABLE_TESTS=ON \
    -DENABLE_XML=ON -DENABLE_JSON=ON -DENABLE_NET=ON -DENABLE_UTIL=ON \
    -DENABLE_CRYPTO=ON -DENABLE_NETSSL=ON -DENABLE_JWT=ON \
    -DENABLE_ENCODINGS=ON -DENABLE_PDF=ON \
    -DENABLE_ZIP=ON -DENABLE_SEVENZIP=ON \
    -DENABLE_REDIS=ON -DENABLE_MONGODB=ON -DENABLE_SSH=ON \
    -DENABLE_DATA=ON -DENABLE_DATA_SQLITE=ON \
    -DENABLE_PROMETHEUS=ON \
    -DENABLE_ACTIVERECORD=ON -DENABLE_ACTIVERECORD_COMPILER=ON \
    -DENABLE_CPPPARSER=ON \
    -DENABLE_PAGECOMPILER=ON -DENABLE_POCODOC=ON -DENABLE_PAGECOMPILER_FILE2PAGE=ON \
    -DENABLE_APACHECONNECTOR=ON \
    -DENABLE_DNSSD=ON -DENABLE_DNSSD_DEFAULT=ON

# Build the project
cmake --build cmake-build --target all --parallel $(nproc)

# Run tests with retry mechanism
cd cmake-build
PWD=`pwd`
for attempt in {1..3}; do
    ctest --output-on-failure --no-tests=error --output-junit test-report.xml --test-output-size-failed 0 --test-output-truncation tail --parallel $(nproc) && break
    echo "Test attempt $attempt failed, retrying..."
    sleep 10
done