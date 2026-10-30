#!/bin/bash

set -e
set -o pipefail

# Activate environment variables if needed
export CCACHE_BASEDIR=$(pwd)
export CCACHE_DIR=$(pwd)/.ccache
export CCACHE_COMPRESS=true
export CCACHE_COMPRESSLEVEL=9
export CCACHE_MAXSIZE=100M

# Install project dependencies
tools/retry.sh wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
tools/retry.sh apt-add-repository -n 'deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main'
tools/retry.sh apt-get update
tools/retry.sh apt-get -y install build-essential ccache clang-17 cmake curl extra-cmake-modules git libasound2-dev libaio-dev libcurl4-openssl-dev libdbus-1-dev libdecor-0-dev libegl-dev libevdev-dev libfontconfig-dev libfreetype-dev libfuse2 libgtk-3-dev libgudev-1.0-dev libharfbuzz-dev libinput-dev libopengl-dev libopus-dev libpcap-dev libpipewire-0.3-dev libpulse-dev libssl-dev libudev-dev libva-dev libvpl2 libvpl-dev libwayland-dev libx11-dev libx11-xcb-dev libx264-dev libxcb1-dev libxcb-composite0-dev libxcb-cursor-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev libxcb-xfixes0-dev libxcb-xinput-dev libxcb-xkb-dev libxext-dev libxkbcommon-x11-dev libxrandr-dev lld-17 llvm-17 nasm ninja-build patchelf pkg-config zlib1g-dev

# Build dependencies
if [ ! -d "$HOME/deps" ]; then
    BUILD_FFMPEG=1 .github/workflows/scripts/linux/build-dependencies-qt.sh "$HOME/deps"
fi

# Download patches
cd bin/resources
aria2c -Z "https://github.com/PCSX2/pcsx2_patches/releases/latest/download/patches.zip"
cd -

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
    -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON

# Build PCSX2
cd build
ccache -p
ccache -z
ninja
ccache -s

# Run tests
ninja unittests || true

# Package AppImage if needed
if [ "$1" == "package" ]; then
    .github/workflows/scripts/linux/appimage-qt.sh "$(realpath .)" "$(realpath ./build)" "$HOME/deps" "PCSX2-linux-Qt-x64-appimage"
    mkdir -p "$GITHUB_WORKSPACE"/ci-artifacts/
    mv "PCSX2-linux-Qt-x64-appimage.AppImage" "$GITHUB_WORKSPACE"/ci-artifacts/
fi