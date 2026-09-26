FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install basic dependencies and add repositories
RUN apt-get update && apt-get install -y \
    wget \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add LLVM 21 repository
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main"

# Add GCC Toolchain PPA (plucky for newer binutils)
RUN add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu plucky main universe"

# Enable i386 architecture
RUN dpkg --add-architecture i386

# Update and install all required packages
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    ninja-build \
    zip \
    unzip \
    curl \
    pkg-config \
    ca-certificates \
    clang-21 \
    lld-21 \
    libc++-21-dev \
    libc++abi-21-dev \
    gcc-15-multilib \
    g++-15-multilib \
    binutils \
    && rm -rf /var/lib/apt/lists/*

# Set up alternatives for Clang
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-21 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100

# Set up alternatives for GCC
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-15 100

# Create workspace directory
WORKDIR /workspace

# Copy the entire repository (including .git and all source files)
COPY . /workspace/

# Copy run.sh and make it executable
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]