FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y --no-install-recommends tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV CI=true GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    autoconf \
    libtool \
    crossbuild-essential-amd64 \
    make \
    gcc \
    g++ \
    git \
    curl \
    wget \
    file \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]