FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc \
      g++ \
      git \
      meson \
      ninja-build \
      python3 \
      python3-pip \
      pkg-config \
      make \
      binutils \
      libasound2-dev \
      libavcodec-dev \
      libavfilter-dev \
      libavformat-dev \
      libavutil-dev \
      libswscale-dev \
      libswresample-dev \
      libass-dev \
      liblua5.2-dev \
      libpulse-dev \
      libx11-dev \
      libxfixes-dev \
      libxkbcommon-dev \
      libxrandr-dev \
      libxpresent-dev \
      libxss-dev \
      rustc \
      cargo \
      libwayland-dev \
      wayland-protocols \
      libarchive-dev \
      libbluray-dev \
      libcaca-dev \
      libcdio-paranoia-dev \
      libdvdnav-dev \
      libdvdread-dev \
      librubberband-dev \
      libzimg-dev \
      libopenal-dev \
      libv4l-dev \
      libuchardet-dev \
      vulkan-tools \
      libvulkan-dev \
      libmujs-dev \
      libpipewire-0.3-dev \
      libgtest-dev \
      zlib1g-dev \
      glslang-tools \
      libepoxy-dev

# Build libplacebo from source (Ubuntu 24.04's version is too old)
RUN cd /tmp && \
    git clone https://github.com/haasn/libplacebo.git && \
    cd libplacebo && \
    git submodule update --init && \
    meson setup build -Dprefix=/usr -Ddefault_library=shared -Dopengl=disabled -Dd3d11=disabled -Dvulkan=disabled && \
    meson compile -C build && \
    meson install -C build && \
    cd .. && rm -rf libplacebo

WORKDIR /app
COPY repo/ /app/
COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
