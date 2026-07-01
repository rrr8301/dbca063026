FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y \
    gcc-14 \
    g++-14 \
    make \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- "https://cmake.org/files/v3.28/cmake-3.28.0-linux-x86_64.tar.gz" | tar --strip-components=1 -xz -C /usr/local

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p /app/build && \
    cd /app/build && \
    CC=gcc-14 CXX=g++-14 cmake -DENTT_BUILD_TESTING=ON -DENTT_BUILD_LIB=ON -DENTT_BUILD_EXAMPLE=ON .. && \
    make -j4

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
