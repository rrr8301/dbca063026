#!/bin/bash

set -e
set -o pipefail

# Activate environment variables if needed
export CCACHE_BASEDIR=$(pwd)
export CCACHE_DIR=$(pwd)/.ccache
export CCACHE_COMPRESS=true
export CCACHE_COMPRESSLEVEL=9
export CCACHE_MAXSIZE=100M

# Build dependencies
if [ ! -d "$HOME/deps" ]; then
  BUILD_FFMPEG=1 .github/workflows/scripts/linux/build-dependencies-qt.sh "$HOME/deps"
fi

# Generate CMake
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DCMAKE_PREFIX_PATH="$HOME/deps" \
  -DCMAKE_C_COMPILER=clang-17 \
  -DCMAKE_CXX_COMPILER=clang++-17 \
  -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
  -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld" \
  -DCMAKE_C_COMPILER_LAUNCHER=ccache \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DENABLE_SETCAP=OFF \
  -DDISABLE_ADVANCE_SIMD=TRUE \
  -DUSE_LINKED_FFMPEG=ON \
  -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON \
  -DCMAKE_CXX_FLAGS="-Wno-error=sign-compare -Wno-error=unused-variable"

# Build PCSX2
pushd build
ccache -p
ccache -z
ninja || exit 1
ccache -s
popd

# Run tests
pushd build
ninja unittests || true
popd

# Package AppImage if needed
if [ "$1" == "package" ]; then
  .github/workflows/scripts/linux/appimage-qt.sh "$(realpath .)" "$(realpath ./build)" "$HOME/deps" "PCSX2-linux-Qt-x64-appimage"
  mkdir -p ci-artifacts/
  mv "PCSX2-linux-Qt-x64-appimage.AppImage" ci-artifacts/
fi