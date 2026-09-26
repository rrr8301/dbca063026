FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gcc-14 \
    g++-14 \
    cmake \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

ENV CC=gcc-14
ENV CXX=g++-14

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DZXC_NATIVE_ARCH=OFF

RUN cmake --build build --config Release --parallel

COPY run.sh /run.sh

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
