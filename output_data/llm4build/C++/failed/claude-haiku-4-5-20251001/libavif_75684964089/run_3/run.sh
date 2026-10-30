#!/bin/bash
set -e

# Set compiler to GCC 14
export CC=gcc-14
export CXX=g++-14

# Ensure Rust is available
export PATH="/home/testuser/.cargo/bin:${PATH}"

# Print versions for debugging
echo "=== Build Environment ==="
gcc-14 --version
g++-14 --version
cmake --version
ninja --version
rustc --version
cargo --version
python3 --version
echo "========================="

# Prepare libavif (cmake)
echo "Configuring libavif with CMake..."
cmake -G Ninja -S . -B build \
  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF \
  -DAVIF_CODEC_AOM=LOCAL -DAVIF_CODEC_DAV1D=LOCAL \
  -DAVIF_CODEC_RAV1E=LOCAL -DAVIF_CODEC_SVT=LOCAL \
  -DAVIF_OPTIMIZE_RAV1E_FOR_SIZE=ON \
  -DAVIF_CODEC_LIBGAV1=LOCAL \
  -DAVIF_LIBSHARPYUV=LOCAL -DAVIF_LIBXML2=LOCAL -DAVIF_LIBYUV=LOCAL \
  -DAVIF_BUILD_EXAMPLES=ON -DAVIF_BUILD_APPS=ON \
  -DAVIF_BUILD_TESTS=ON -DAVIF_GTEST=LOCAL \
  -DAVIF_ENABLE_EXPERIMENTAL_MINI=ON \
  -DAVIF_ENABLE_EXPERIMENTAL_EXTENDED_PIXI=ON \
  -DAVIF_ENABLE_WERROR=ON

# Build libavif
echo "Building libavif..."
cmake --build build --config Release --parallel 4

# Run AVIF Tests
echo "Running AVIF tests..."
cd ./build
ctest -j $(getconf _NPROCESSORS_ONLN) --output-on-failure

echo "=== All tests completed ==="