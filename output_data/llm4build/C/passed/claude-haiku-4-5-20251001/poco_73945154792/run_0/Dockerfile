FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV CI=true GITHUB_ACTIONS=true

# Install build tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    g++ \
    gcc \
    make \
    curl \
    wget \
    libssl-dev \
    libssh-dev \
    libltdl-dev \
    apache2-dev \
    libapr1-dev \
    libaprutil1-dev \
    libavahi-client-dev \
    libsqlite3-dev \
    redis-server \
    mongodb \
    sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatches
RUN git config --global --add safe.directory '*'

# Create non-root user (but we need root for services, so skip for now)
# Services like Redis and MongoDB require root to start
# RUN useradd -m testuser && chown -R testuser /workspace
# USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]