FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    BUILD_TYPE=RELWITHDEBINFO

# Install tzdata first to avoid prompts
RUN apt-get update -qq && \
    apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Update apt and add PPAs (only libheif, libde265 is in standard repos)
RUN apt-get update -qq -o Acquire::Retries=3 && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:strukturag/libheif && \
    apt-get update -qq -o Acquire::Retries=3

# Install dependencies
RUN apt-get install --fix-missing -qq -o Acquire::Retries=3 -y \
    cmake \
    clang \
    lld \
    gcc \
    g++ \
    build-essential \
    curl \
    git \
    libjpeg-turbo8-dev \
    libimagequant-dev \
    libde265-dev \
    libpng-dev \
    libwebp-dev \
    libtiff5-dev \
    libx265-dev \
    libheif-dev \
    libheif-plugin-aomenc \
    libheif-plugin-x265 \
    libheif-plugin-aomdec \
    libfreetype-dev \
    libavif-dev \
    libavifile-0.7-dev \
    libxpm-dev \
    libraqm-dev \
    libexiv2-dev \
    dh-autoreconf \
    ninja-build \
    nasm \
    meson \
    pkg-config \
    autoconf \
    automake \
    libtool

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow workspace directory
RUN git config --global --add safe.directory '*'

# Build and install libultrahdr
RUN curl -L -o /tmp/libultrahdr-1.4.0.tar.gz https://github.com/google/libultrahdr/archive/refs/tags/v1.4.0.tar.gz && \
    mkdir -p /tmp/libultrahdr-src /tmp/libultrahdr-build && \
    tar -xzf /tmp/libultrahdr-1.4.0.tar.gz -C /tmp/libultrahdr-src --strip-components=1 && \
    cmake -S /tmp/libultrahdr-src -B /tmp/libultrahdr-build -G "Ninja" \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DUHDR_BUILD_TESTS=1 && \
    cmake --build /tmp/libultrahdr-build && \
    cmake --install /tmp/libultrahdr-build && \
    ldconfig && \
    rm -rf /tmp/libultrahdr-src /tmp/libultrahdr-build /tmp/libultrahdr-1.4.0.tar.gz

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]