#!/bin/bash
set -e

# Set timezone to Europe/Kyiv (as per workflow)
sudo timedatectl set-timezone 'Europe/Kyiv' || timedatectl set-timezone 'Europe/Kyiv' || true

# Add Ubuntu mirrors (optional, may not work in container)
mirrors=/etc/apt/mirrors.txt
printf 'http://azure.archive.ubuntu.com/ubuntu\tpriority:1\n' | tee $mirrors 2>/dev/null || true
curl -s http://mirrors.ubuntu.com/mirrors.txt | tee --append $mirrors 2>/dev/null || true
sed -i "s~http://azure.archive.ubuntu.com/ubuntu/~mirror+file:$mirrors~" /etc/apt/sources.list 2>/dev/null || true

# Create build directory
mkdir -p /workspace/build

# Configure CMake
cd /workspace/build
export CXX=clang++-14
export CXXFLAGS="-fsanitize=address,undefined -fno-sanitize-recover=all -fno-omit-frame-pointer"

cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_CXX_STANDARD=20 \
      -DCMAKE_CXX_VISIBILITY_PRESET=hidden \
      -DCMAKE_VISIBILITY_INLINES_HIDDEN=ON \
      -DFMT_DOC=OFF -DFMT_PEDANTIC=ON -DFMT_WERROR=ON \
      /workspace

# Build
threads=$(nproc)
cmake --build . --config Debug --parallel $threads

# Test
export CTEST_OUTPUT_ON_FAILURE=True
ctest -C Debug

echo "Build and tests completed successfully!"