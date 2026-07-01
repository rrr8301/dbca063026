FROM ubuntu:26.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Install base build tools and git
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    autoconf \
    automake \
    libtool \
    make \
    g++-14-arm-linux-gnueabi \
    qemu-user \
    xz-utils \
    abigail-tools \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatches
RUN git config --global --add safe.directory '*'

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]