FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    wget \
    curl \
    build-essential \
    clang-19 \
    clang-tidy-19 \
    clang-format-19 \
    lld-19 \
    python3.10 \
    python3.10-venv \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for clang tools to standard names
RUN ln -s /usr/bin/clang-19 /usr/bin/clang && \
    ln -s /usr/bin/clang++-19 /usr/bin/clang++ && \
    ln -s /usr/bin/clang-tidy-19 /usr/bin/clang-tidy && \
    ln -s /usr/bin/clang-format-19 /usr/bin/clang-format && \
    ln -s /usr/bin/lld-19 /usr/bin/lld

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Install pip and upgrade it
RUN python3.10 -m pip install --upgrade pip setuptools wheel

# Install bazelisk
RUN wget -q https://github.com/bazelbuild/bazelisk/releases/download/v1.20.0/bazelisk-linux-amd64 -O /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk && \
    ln -s /usr/local/bin/bazelisk /usr/local/bin/bazel

# Download and cache LLVM 19.1.7
RUN mkdir -p /opt/llvm && \
    cd /tmp && \
    LLVM_RELEASE=19.1.7 && \
    LLVM_TARBALL_NAME=LLVM-$LLVM_RELEASE-Linux-X64 && \
    wget -q "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_RELEASE/$LLVM_TARBALL_NAME.tar.xz" && \
    tar -xJf $LLVM_TARBALL_NAME.tar.xz --strip-components=1 -C /opt/llvm && \
    rm $LLVM_TARBALL_NAME.tar.xz && \
    # Prune unnecessary files to reduce image size
    rm -f /opt/llvm/lib/*.a /opt/llvm/lib/*.so* && \
    rm -f /opt/llvm/bin/{flang-*,mlir-*,clang-{scan-deps,check,repl},*-test,llvm-{lto*,reduce,bolt*,exegesis,jitlink},bugpoint,opt,llc}

# Add LLVM to PATH
ENV PATH="/opt/llvm/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install Python dependencies from pyproject.toml and requirements.txt if they exist
RUN if [ -f /workspace/pyproject.toml ]; then \
      python3.10 -m pip install -e /workspace; \
    fi && \
    if [ -f /workspace/github_tools/requirements.txt ]; then \
      python3.10 -m pip install -r /workspace/github_tools/requirements.txt; \
    fi

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]