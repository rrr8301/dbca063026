FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    binutils \
    cmake \
    clang-14 \
    doctest-dev \
    elfutils \
    g++-multilib \
    git \
    lld-14 \
    libfmt-dev \
    libhiredis-dev \
    libxxhash-dev \
    libzstd-dev \
    ninja-build \
    python3 \
    redis-server \
    redis-tools

RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100 \
    && update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100

WORKDIR /app

COPY repo/ /app/

ENV CC=clang-14
ENV CXX=clang++-14
ENV CMAKE_GENERATOR=Ninja
ENV CMAKE_PARAMS="-D CMAKE_BUILD_TYPE=CI -D DEPS=LOCAL"
ENV CTEST_OUTPUT_ON_FAILURE=ON
ENV VERBOSE=1

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
