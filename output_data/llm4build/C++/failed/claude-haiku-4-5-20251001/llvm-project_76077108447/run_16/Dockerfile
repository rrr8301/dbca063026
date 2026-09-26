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
# For Ubuntu 24.04 (Noble), use the auto repository which handles version detection
RUN wget -O /etc/apt/trusted.gpg.d/llvm-snapshot.gpg.asc https://apt.llvm.org/llvm-snapshot.gpg.key && \
    add-apt-repository "deb http://apt.llvm.org/noble/ llvm-toolchain-noble main" && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    clang-23 \
    lld-23 \
    llvm-23 \
    llvm-23-dev \
    libclang-23-dev \
    libomp-23-dev \
    libffi-dev \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo "clang-23 and llvm-23 installation completed"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Make all scripts executable
RUN find /workspace -name "run-buildbot" -type f -exec chmod +x {} \; && \
    find /workspace -name "*.sh" -type f -exec chmod +x {} \;

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]