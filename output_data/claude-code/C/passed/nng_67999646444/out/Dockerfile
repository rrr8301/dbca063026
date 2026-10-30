FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    libmbedtls-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN mkdir build.mbed && \
    cd build.mbed && \
    cmake -G Ninja \
        -DCMAKE_BUILD_TYPE=Debug \
        -DNNG_ENABLE_TLS=ON \
        -DNNG_POLLQ_POLLER=auto \
        -DNNG_TLS_ENGINE=mbed \
        .. && \
    ninja

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
