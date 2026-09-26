FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CTEST_OUTPUT_ON_FAILURE=ON
ENV VERBOSE=1
ENV CMAKE_GENERATOR=Ninja
ENV CC=gcc-11
ENV CXX=g++-11
ENV CMAKE_PARAMS="-D CMAKE_BUILD_TYPE=CI -D DEPS=LOCAL"

RUN apt-get update && apt-get install -y \
    cmake \
    curl \
    elfutils \
    g++-11 \
    g++-11-multilib \
    gcc-11 \
    git \
    libfmt-dev \
    libhiredis-dev \
    libxxhash-dev \
    libzstd-dev \
    ninja-build \
    python3 \
    doctest-dev \
    binutils \
    redis-server \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
