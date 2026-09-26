FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Update package lists with proper error handling
RUN apt-get update -qq && \
    apt-get upgrade -y -qq

# Install dependencies
RUN apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    ninja-build \
    python3 \
    python3-venv \
    python3-pip \
    wget \
    curl \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install clang-23 from pre-built binaries with verbose error output
RUN mkdir -p /opt && \
    cd /tmp && \
    echo "Downloading clang+llvm-23.0.0..." && \
    wget --timeout=300 --tries=5 --waitretry=10 -v https://github.com/llvm/llvm-project/releases/download/llvmorg-23.0.0/clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz 2>&1 | tail -20 && \
    if [ ! -f clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz ]; then \
        echo "Download failed, checking available releases..."; \
        exit 1; \
    fi && \
    echo "Extracting archive..." && \
    tar -xf clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    mv clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04 /opt/clang-23 && \
    rm clang+llvm-23.0.0-x86_64-linux-gnu-ubuntu-22.04.tar.xz && \
    ln -s /opt/clang-23/bin/clang /usr/local/bin/clang-23 && \
    ln -s /opt/clang-23/bin/clang++ /usr/local/bin/clang++-23 && \
    ln -s /opt/clang-23/bin/lld /usr/local/bin/lld-23 && \
    echo "clang-23 installation completed"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]