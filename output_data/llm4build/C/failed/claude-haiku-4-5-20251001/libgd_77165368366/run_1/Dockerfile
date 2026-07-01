FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV BUILD_TYPE=RELWITHDEBINFO

# Install basic tools and git
RUN apt-get update -qq -o Acquire::Retries=3 && \
    apt-get install -y -qq \
    git \
    curl \
    wget \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add PPA for libheif only (libde265 is available in standard repos)
RUN add-apt-repository ppa:strukturag/libheif

# Update apt after adding PPA
RUN apt-get update -qq -o Acquire::Retries=3

# Install build dependencies
RUN apt-get install --fix-missing -y -qq -o Acquire::Retries=3 \
    cmake \
    clang \
    lld \
    gcc \
    g++ \
    build-essential \
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
    dh-autoreconf \
    ninja-build \
    nasm \
    meson \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository (assumes repo is available in build context)
COPY . /workspace/

# Configure git safe directory to avoid ownership errors
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint to run.sh
ENTRYPOINT ["/workspace/run.sh"]