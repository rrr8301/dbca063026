FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    clang-tidy \
    cmake \
    curl \
    g++ \
    git \
    make \
    ninja-build \
    python3.10 \
    python3-pip \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install bazelisk
RUN wget -q https://github.com/bazelbuild/bazelisk/releases/download/v1.19.0/bazelisk-linux-amd64 -O /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk && \
    ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

# Download and install LLVM 19.1.7
RUN mkdir -p /opt/llvm && \
    cd /tmp && \
    wget -q https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.7/LLVM-19.1.7-Linux-X64.tar.xz && \
    tar -xJf LLVM-19.1.7-Linux-X64.tar.xz --strip-components=1 -C /opt/llvm && \
    rm LLVM-19.1.7-Linux-X64.tar.xz && \
    rm -f /opt/llvm/lib/{*.a,*.so,*.so.*} && \
    rm -f /opt/llvm/bin/{flang-*,mlir-*,clang-{scan-deps,check,repl},*-test,llvm-{lto*,reduce,bolt*,exegesis,jitlink},bugpoint,opt,llc}

# Add LLVM to PATH
ENV PATH="/opt/llvm/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make scripts executable
RUN chmod +x /workspace/scripts/*.py /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]