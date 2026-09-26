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
    ca-certificates \
    lsb-release \
    software-properties-common && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add LLVM repository for clang-23
# For Ubuntu 24.04 (Noble), use the jammy repository as a fallback or use universe
RUN wget -O /etc/apt/trusted.gpg.d/llvm-snapshot.gpg https://apt.llvm.org/llvm-snapshot.gpg.key && \
    add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-23 main" && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    clang-23 \
    lld-23 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "clang-23 installation completed"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]