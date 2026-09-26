FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/cmake-3.15 && \
    cd /tmp/cmake-3.15 && \
    curl -L https://github.com/Kitware/CMake/releases/download/v3.15.7/cmake-3.15.7-Linux-x86_64.tar.gz -o cmake.tar.gz && \
    tar -xzf cmake.tar.gz && \
    cp cmake-3.15.7-Linux-x86_64/bin/cmake /usr/local/bin/ && \
    cp -r cmake-3.15.7-Linux-x86_64/share/cmake-3.15 /usr/local/share/ && \
    rm -rf /tmp/cmake-3.15

WORKDIR /app

COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
