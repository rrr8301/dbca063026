FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Los_Angeles

# Install system dependencies for building and running tests
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    clang \
    git \
    wget \
    curl \
    pkg-config \
    autoconf \
    automake \
    libtool \
    m4 \
    python3.12 \
    python3.12-dev \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the repository
WORKDIR /app
COPY repo/ /app/

# Install bazelisk
RUN wget -O /usr/local/bin/bazel \
    https://github.com/bazelbuild/bazelisk/releases/download/v1.25.0/bazelisk-linux-amd64 && \
    chmod +x /usr/local/bin/bazel

# Copy and set executable permission on run.sh
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
