FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y \
    git \
    gcc \
    gcc-multilib \
    g++-multilib \
    ninja-build \
    libpng-dev \
    libjpeg-turbo8-dev \
    libwebp-dev \
    libfreetype-dev \
    libglfw3-dev \
    libsdl2-dev \
    libpng-dev:i386 \
    libjpeg-dev:i386 \
    libwebp-dev:i386 \
    libfreetype-dev:i386 \
    libsdl2-dev:i386 \
    ruby-full \
    gcovr \
    cmake \
    python3 \
    python3-pip \
    libinput-dev \
    libxkbcommon-dev \
    libdrm-dev \
    pkg-config \
    wayland-protocols \
    libwayland-dev \
    libwayland-bin \
    libwayland-dev:i386 \
    libxkbcommon-dev:i386 \
    libudev-dev \
    libavformat-dev \
    libavcodec-dev \
    libswscale-dev \
    libavutil-dev \
    libavformat-dev:i386 \
    libavcodec-dev:i386 \
    libswscale-dev:i386 \
    libavutil-dev:i386 \
    libuv1-dev \
    libuv1-dev:i386 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages pypng lz4 kconfiglib

WORKDIR /app
COPY repo/ /app/

RUN cd /app && scripts/install_pngquant.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
