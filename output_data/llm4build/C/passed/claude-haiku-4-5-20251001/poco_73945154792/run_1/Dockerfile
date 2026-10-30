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
    sudo \
    gnupg \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install MongoDB from official MongoDB repository
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | apt-key add - && \
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    mongodb-org-server \
    mongodb-org-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatches
RUN git config --global --add safe.directory '*'

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]