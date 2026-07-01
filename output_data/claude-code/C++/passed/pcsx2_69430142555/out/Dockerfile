FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl gnupg2 lsb-release software-properties-common wget

RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    apt-add-repository -n 'deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-17 main' && \
    apt-get update && apt-get install -y \
    build-essential ccache clang-17 cmake curl extra-cmake-modules git libasound2-dev libaio-dev \
    libcurl4-openssl-dev libdbus-1-dev libdecor-0-dev libegl-dev libevdev-dev libfontconfig-dev libfreetype-dev libfuse2 libgtk-3-dev libgudev-1.0-dev \
    libharfbuzz-dev libinput-dev libopengl-dev libopus-dev libpcap-dev libpipewire-0.3-dev libpulse-dev libssl-dev libudev-dev libva-dev libvpl2 libvpl-dev \
    libwayland-dev libx11-dev libx11-xcb-dev libx264-dev libxcb1-dev libxcb-composite0-dev libxcb-cursor-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-icccm4-dev \
    libxcb-image0-dev libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev \
    libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev libxcb-xfixes0-dev libxcb-xinput-dev libxcb-xkb-dev libxext-dev libxkbcommon-x11-dev libxrandr-dev \
    lld-17 llvm-17 nasm ninja-build patchelf pkg-config zlib1g-dev aria2

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p /root/deps

ENV BUILD_FFMPEG=1
ENV HOME=/root
ENV CCACHE_BASEDIR=/app
ENV CCACHE_DIR=/app/.ccache
ENV CCACHE_COMPRESS=true
ENV CCACHE_COMPRESSLEVEL=9
ENV CCACHE_MAXSIZE=100M

RUN bash -c './.github/workflows/scripts/linux/build-dependencies-qt.sh "$HOME/deps"'

RUN cd bin/resources && aria2c -Z https://github.com/PCSX2/pcsx2_patches/releases/latest/download/patches.zip

RUN cmake -B build -G Ninja \
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

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
