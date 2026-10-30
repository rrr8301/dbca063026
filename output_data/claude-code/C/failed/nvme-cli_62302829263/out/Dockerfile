FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    ninja-build \
    gcc \
    clang \
    git \
    python3 \
    python3-dev \
    python3-pip \
    valgrind \
    libssl-dev \
    libkeyutils-dev \
    libdbus-1-dev \
    libjson-c-dev \
    libkmod-dev \
    liburing-dev \
    pkg-config \
    swig \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install meson>=0.62.0

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
