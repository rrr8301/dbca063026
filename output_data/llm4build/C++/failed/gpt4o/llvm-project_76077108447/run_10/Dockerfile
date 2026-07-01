FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    git \
    python3 \
    python3-venv \
    python3-pip \
    cmake \
    make \
    ninja-build \
    lsb-release \
    software-properties-common \
    libedit-dev \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libffi-dev \
    libxml2-dev \
    libzstd-dev \  # Added zstd library
    && rm -rf /var/lib/apt/lists/*

# Add LLVM repository and install clang-23
RUN wget https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 23 all && \  # Install all components of LLVM
    rm llvm.sh

# Install Sphinx for documentation
RUN pip install sphinx

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure the run-buildbot script is executable
RUN chmod +x libcxx/utils/ci/run-buildbot

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]