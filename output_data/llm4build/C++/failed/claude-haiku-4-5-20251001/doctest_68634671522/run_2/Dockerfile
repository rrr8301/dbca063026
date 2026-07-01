FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    gpg \
    curl \
    build-essential \
    python3 \
    cmake \
    ninja-build \
    valgrind \
    g++-multilib \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add i386 architecture support
RUN dpkg --add-architecture i386

# Configure LLVM upstream repository
RUN wget -qO- http://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-22 main" && \
    apt-get update

# Install required dependencies
RUN apt-get install -y \
    libxml2-dev \
    libffi-dev \
    libncurses-dev \
    libz3-dev \
    libc6-dbg:i386 \
    clang-22 \
    libclang-22-dev \
    llvm-22-dev \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]