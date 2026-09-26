FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    build-essential \
    cmake \
    autoconf \
    automake \
    libtool \
    pkg-config \
    curl \
    wget \
    ca-certificates \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install Python 3.10
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Ruby 2.7 from standard Ubuntu repositories
RUN apt-get update && apt-get install -y --no-install-recommends \
    ruby2.7 \
    ruby2.7-dev \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby2.7 1

# Install Maven
RUN apt-get update && apt-get install -y --no-install-recommends \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 17 (Temurin)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]