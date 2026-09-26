FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    libgtest-dev \
    pkg-config \
    doxygen \
    graphviz \
    libomp-dev \
    clang \
    llvm \
    && rm -rf /var/lib/apt/lists/*

# Install sccache
RUN curl -L https://github.com/mozilla/sccache/releases/download/v0.7.7/sccache-v0.7.7-x86_64-unknown-linux-musl.tar.gz \
    | tar xz -C /usr/local/bin --strip-components=1

WORKDIR /app

# Copy repository
COPY repo/ /app/

# Initialize git configuration and update submodules
RUN cd /app && \
    git config --global --add safe.directory /app && \
    git submodule sync --recursive && \
    git submodule update --init --recursive

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
