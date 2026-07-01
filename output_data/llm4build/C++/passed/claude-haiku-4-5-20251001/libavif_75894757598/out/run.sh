#!/bin/bash
set -e

# Set compiler environment variables
export CC=gcc-14
export CXX=g++-14

# Source Rust environment if it exists
if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

# Ensure cmake and ninja are available
which cmake
which ninja

# Print versions for debugging
echo "=== Build Environment ==="
gcc-14 --version
g++-14 --version
cmake --version
ninja --version
python3 --version
rustc --version
cargo --version
meson --version

# Configure libavif with CMake
echo "=== Configuring libavif ==="
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
echo "=== Building libavif ==="
cmake --build build --config Release --parallel 4

# Run AVIF Tests
echo "=== Running AVIF Tests ==="
cd build
ctest -j $(getconf _NPROCESSORS_ONLN) --output-on-failure
cd ..

# Check static link bundling
echo "=== Checking static link bundling ==="
cc -o avifenc  -I./apps/shared -I./third_party/iccjpeg -I./include apps/avifenc.c \
  -I/opt/homebrew/include/ -L/opt/homebrew/lib \
  apps/shared/*.c third_party/iccjpeg/iccjpeg.c build/libavif.a \
  -lpng -ljpeg -lz -lm -ldl -lstdc++

./avifenc --help

echo "=== All tests completed successfully ==="