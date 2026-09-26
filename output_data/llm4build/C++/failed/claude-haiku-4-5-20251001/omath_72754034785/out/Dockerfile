FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install basic dependencies and add LLVM repository
RUN apt-get update && apt-get install -y \
    wget curl ca-certificates gnupg lsb-release software-properties-common && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" && \
    apt-get update

# Install build tools, Clang 21 toolchain, and GCC 14 (for libstdc++ with C++23 support)
RUN apt-get install -y \
    git build-essential cmake ninja-build \
    zip unzip curl pkg-config ca-certificates \
    clang-21 lld-21 \
    llvm-21 lcov \
    gcc-14 g++-14 libstdc++-14-dev

# Set up alternatives for clang/clang++/lld to use GCC 14's libstdc++
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-21 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100

# Create workspace
WORKDIR /workspace

# Copy repository code into the container
COPY . /workspace/repo

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]