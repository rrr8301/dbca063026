FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install -y \
    clang-19 \
    cmake \
    g++-13 \
    gcc-13 \
    git \
    gperf \
    libgl1-mesa-dev \
    libglvnd-dev \
    libharfbuzz-dev \
    libqt6svg6-dev \
    libxcursor-dev \
    libxi-dev \
    libxinerama-dev \
    libxrandr-dev \
    ninja-build \
    pkg-config \
    qt6-base-dev \
    qt6-positioning-dev

# Install ccache
RUN apt install -y ccache

# Prepare locales for tests
RUN apt install -y locales && \
    locale-gen en_US && \
    locale-gen en_US.UTF-8 && \
    locale-gen es_ES && \
    locale-gen es_ES.UTF-8 && \
    locale-gen fr_FR && \
    locale-gen fr_FR.UTF-8 && \
    locale-gen ru_RU && \
    locale-gen ru_RU.UTF-8 && \
    update-locale

WORKDIR /app

COPY repo/ /app/

RUN git submodule update --depth 1 --init --recursive --jobs=20

RUN ./configure.sh

ENV CC=gcc-13
ENV CXX=g++-13
ENV CMAKE_C_COMPILER_LAUNCHER=ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
ENV BUILD_DIR=build

RUN cmake . -B ${BUILD_DIR} -G Ninja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_C_FLAGS=-g1 \
    -DCMAKE_CXX_FLAGS=-g1 \
    -DCMAKE_UNITY_BUILD=ON

WORKDIR /app/${BUILD_DIR}

RUN ninja

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
