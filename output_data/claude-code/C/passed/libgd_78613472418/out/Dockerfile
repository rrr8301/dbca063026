FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y -qq software-properties-common curl wget gpg git && \
    add-apt-repository -y ppa:strukturag/libde265 || true && \
    add-apt-repository -y ppa:strukturag/libheif || true && \
    apt-get update -qq -o Acquire::Retries=3 || true

RUN apt-get install --fix-missing -y -qq -o Acquire::Retries=3 \
    cmake clang lld gcc build-essential curl libjpeg-turbo8-dev libimagequant-dev \
    libde265-dev libpng-dev libwebp-dev libtiff5-dev libx265-dev libheif-dev \
    libheif-plugin-aomenc libheif-plugin-x265 libheif-plugin-aomdec libfreetype-dev \
    libavif-dev libavifile-0.7-dev libxpm-dev libraqm-dev libexiv2-dev dh-autoreconf \
    ninja-build nasm meson autoconf automake libtool pkg-config zlib1g-dev

RUN curl -L -o /tmp/libultrahdr-1.4.0.tar.gz https://github.com/google/libultrahdr/archive/refs/tags/v1.4.0.tar.gz && \
    mkdir -p /tmp/libultrahdr-src /tmp/libultrahdr-build && \
    tar -xzf /tmp/libultrahdr-1.4.0.tar.gz -C /tmp/libultrahdr-src --strip-components=1 && \
    cmake -S /tmp/libultrahdr-src -B /tmp/libultrahdr-build -G "Ninja" \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DUHDR_BUILD_TESTS=1 && \
    cmake --build /tmp/libultrahdr-build && \
    cmake --install /tmp/libultrahdr-build && \
    ldconfig && \
    rm -rf /tmp/libultrahdr-*

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
