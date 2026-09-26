FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=America/Los_Angeles \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    CI=true \
    GITHUB_ACTIONS=true \
    FORCE_COLOR=1 \
    OPENSSL_VER=3.5.6 \
    PYTHONSTRICTEXTENSIONBUILD=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    curl \
    wget \
    pkg-config \
    autoconf \
    automake \
    libtool \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses-dev \
    zlib1g-dev \
    liblzma-dev \
    libgdbm-dev \
    libdb-dev \
    tk-dev \
    uuid-dev \
    python3 \
    python3-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user with sudo privileges
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/testuser && \
    chmod 0440 /etc/sudoers.d/testuser

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]