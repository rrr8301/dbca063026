FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    unzip \
    pkg-config \
    xorg-dev \
    libharfbuzz-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxi-dev \
    libudev-dev \
    libflac-dev \
    libvorbis-dev \
    libgl1-mesa-dev \
    libegl1-mesa-dev \
    libdrm-dev \
    libgbm-dev \
    libmbedtls-dev \
    libssh2-1-dev \
    xvfb \
    fluxbox \
    ccache \
    gcovr \
    clang \
    && rm -rf /var/lib/apt/lists/*

# Install CMake 3.28
RUN curl -fsSL https://github.com/Kitware/CMake/releases/download/v3.28.0/cmake-3.28.0-linux-x86_64.tar.gz -o cmake.tar.gz && \
    tar -xzf cmake.tar.gz -C /usr/local --strip-components=1 && \
    rm cmake.tar.gz

# Install Ninja
RUN curl -fsSL https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip -o ninja.zip && \
    unzip ninja.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/ninja && \
    rm ninja.zip

WORKDIR /app

COPY repo/ /app/

# Configure CMake
RUN cmake --preset dev \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DSFML_RUN_IPV4_LINK_TESTS=ON \
    -DSFML_RUN_IPV4_INTERNET_TESTS=ON \
    -DSFML_RUN_IPV6_LINK_TESTS=ON \
    -DSFML_NETWORK_TESTS_MAX_FDS=1028 \
    -GNinja \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Debug \
    -DSFML_ENABLE_COVERAGE=ON \
    -DSFML_FATAL_OPENGL_ERRORS=ON

# Build
RUN cmake --build build --config Debug --target install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
