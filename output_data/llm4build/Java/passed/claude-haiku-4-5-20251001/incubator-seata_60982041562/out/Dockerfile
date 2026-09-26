FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV CI=true
ENV GITHUB_ACTIONS=true

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    tzdata \
    git \
    curl \
    wget \
    build-essential \
    openjdk-17-jdk \
    maven \
    python3 \
    python3-pip \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Download and setup Nacos
RUN mkdir -p /opt/nacos && \
    cd /opt/nacos && \
    wget -q https://github.com/alibaba/nacos/releases/download/2.4.2/nacos-server-2.4.2.tar.gz && \
    tar -xzf nacos-server-2.4.2.tar.gz && \
    rm nacos-server-2.4.2.tar.gz

# Set environment variables for Nacos
ENV NACOS_HOME=/opt/nacos/nacos

# Expose ports
EXPOSE 6379 8848

# Run as root (required for service management)
USER root

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]