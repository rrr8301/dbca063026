FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    software-properties-common \
    git \
    cmake \
    clang \
    lld \
    gcc \
    build-essential \
    libjpeg-turbo8-dev \
    libimagequant-dev \
    libpng-dev \
    libwebp-dev \
    libtiff5-dev \
    libx265-dev \
    libfreetype-dev \
    libavif-dev \
    libavifile-0.7-dev \
    libxpm-dev \
    libraqm-dev \
    dh-autoreconf \
    ninja-build \
    nasm \
    meson \
    wget && \
    wget -qO /usr/share/keyrings/libde265-archive-keyring.gpg https://launchpad.net/~strukturag/+archive/ubuntu/libde265/+files/strukturag-ubuntu-libde265.gpg && \
    wget -qO /usr/share/keyrings/libheif-archive-keyring.gpg https://launchpad.net/~strukturag/+archive/ubuntu/libheif/+files/strukturag-ubuntu-libheif.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/libde265-archive-keyring.gpg] http://ppa.launchpad.net/strukturag/libde265/ubuntu jammy main" | tee /etc/apt/sources.list.d/libde265.list && \
    echo "deb [signed-by=/usr/share/keyrings/libheif-archive-keyring.gpg] http://ppa.launchpad.net/strukturag/libheif/ubuntu jammy main" | tee /etc/apt/sources.list.d/libheif.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libde265-dev \
    libheif-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
COPY . /workspace
RUN chown -R testuser /workspace
RUN git config --global --add safe.directory '*'
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]