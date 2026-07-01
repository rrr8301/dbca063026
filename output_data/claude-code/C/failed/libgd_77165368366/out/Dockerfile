FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq -o Acquire::Retries=3 && \
    apt-get install -qq -y -o Acquire::Retries=3 \
        cmake \
        gcc \
        g++ \
        clang \
        lld \
        build-essential \
        libjpeg-turbo8-dev \
        libimagequant-dev \
        libpng-dev \
        libwebp-dev \
        libtiff5-dev \
        libfreetype-dev \
        libavif-dev \
        libavifile-0.7-dev \
        libxpm-dev \
        libraqm-dev \
        dh-autoreconf \
        ninja-build \
        nasm \
        meson \
        software-properties-common \
        git \
        ca-certificates \
        libde265-dev \
        libx265-dev \
        libheif-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p suppressions && \
    echo "" > suppressions/lsan.supp

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
