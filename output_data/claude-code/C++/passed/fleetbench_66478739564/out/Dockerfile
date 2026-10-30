FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including Python 3.12
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    build-essential \
    clang-15 \
    clang \
    curl \
    git \
    libtool \
    pkg-config \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    openjdk-21-jdk-headless \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && \
    apt-get install -y python3.12 python3.12-dev python3.12-venv && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 100

# Install Bazel 8.0.0
RUN curl -sSL https://github.com/bazelbuild/bazel/releases/download/8.0.0/bazel-8.0.0-linux-x86_64 -o /usr/local/bin/bazel && \
    chmod +x /usr/local/bin/bazel

# Set up alternatives for clang to use clang-15
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100

# Copy repository
WORKDIR /app
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
