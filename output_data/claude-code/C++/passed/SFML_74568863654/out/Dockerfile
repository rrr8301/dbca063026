FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=":99"
ENV GALLIUM_DRIVER=llvmpipe
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache

RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    gcc \
    g++ \
    git \
    xorg-dev \
    libharfbuzz-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libudev-dev \
    libflac-dev \
    libvorbis-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    libmbedtls-dev \
    libssh2-1-dev \
    xvfb \
    fluxbox \
    ccache \
    gcovr \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
