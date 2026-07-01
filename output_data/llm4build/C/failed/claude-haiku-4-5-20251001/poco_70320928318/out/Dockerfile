FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV CI=true
ENV GITHUB_ACTIONS=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    cmake \
    ninja-build \
    libssl-dev \
    unixodbc-dev \
    libmysqlclient-dev \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to allow ownership mismatches
RUN git config --global --add safe.directory '*'

# Create non-root user (skip for this job since redis-server requires root)
# RUN useradd -m testuser && chown -R testuser /workspace
# USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]