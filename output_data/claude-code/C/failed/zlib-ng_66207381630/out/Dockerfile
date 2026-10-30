FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV GTEST_COLOR=1

# Install base dependencies
RUN apt-get update && apt-get install -y --fix-broken \
    build-essential \
    cmake \
    ninja-build \
    clang-18 \
    llvm-18 \
    git \
    curl \
    wget \
    python3 \
    python3-venv \
    libgtest-dev \
    libbenchmark-dev \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for clang/clang++ to default versions
RUN ln -sf /usr/bin/clang-18 /usr/bin/clang && ln -sf /usr/bin/clang++-18 /usr/bin/clang++

WORKDIR /app

COPY repo/ /app/

# Set up LLVM build directory for MSAN
ENV LLVM_BUILD_DIR=/app/llvm-project/build

# Copy and run the build script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
