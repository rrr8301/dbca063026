FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y curl ca-certificates

RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y \
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
    libuv1-dev:i386

RUN pip3 install --break-system-packages pypng lz4 kconfiglib

RUN mkdir -p /tmp/pngquant && \
    cd /tmp/pngquant && \
    git clone https://github.com/kornelski/pngquant . && \
    git checkout 2.17.0 && \
    ./configure && \
    make -j && \
    make install && \
    cd / && \
    rm -rf /tmp/pngquant

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
