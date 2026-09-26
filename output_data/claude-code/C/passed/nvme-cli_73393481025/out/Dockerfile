FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    clang \
    ninja-build \
    pkg-config \
    libssl-dev \
    libudev-dev \
    libdbus-1-dev \
    libkmod-dev \
    libnl-genl-3-dev \
    libpython3-dev \
    swig \
    valgrind \
    ca-certificates \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir meson>=0.62.0

WORKDIR /app

COPY repo/ /app/

RUN chmod +x /app/scripts/build.sh

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
