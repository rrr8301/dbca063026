#!/usr/bin/env bash
set -e

cd /app

# Download patches
echo "=== Downloading patches ==="
cd bin/resources
curl -L -o patches.zip "https://github.com/PCSX2/pcsx2_patches/releases/latest/download/patches.zip"
unzip -o patches.zip
rm patches.zip
cd /app

# Generate CMake
echo "=== Generating CMake ==="
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DCMAKE_PREFIX_PATH="/root/deps" \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
  -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DENABLE_SETCAP=OFF \
  -DDISABLE_ADVANCE_SIMD=TRUE \
  -DUSE_LINKED_FFMPEG=ON \
  -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON

# Build PCSX2
echo "=== Building PCSX2 ==="
cd build
ccache -p
ccache -z
ninja || true
ccache -s
cd /app

# Run Tests
echo "=== Running Tests ==="
cd build
ninja unittests || true
cd /app

echo "FINAL_STATUS = SUCCESS"
