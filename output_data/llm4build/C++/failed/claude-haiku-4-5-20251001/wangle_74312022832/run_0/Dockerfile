FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    locales \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    g++ \
    make \
    clang \
    curl \
    wget \
    python3 \
    python3-dev \
    python3-pip \
    pkg-config \
    libssl-dev \
    libboost-all-dev \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]