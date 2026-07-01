FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git build-essential cmake ninja-build zip unzip curl pkg-config ca-certificates \
    wget software-properties-common \
    && wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc \
    && add-apt-repository -y "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" \
    && add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu plucky main universe" \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y clang-21 lld-21 libc++-21-dev libc++abi-21-dev \
    && apt-get install -y -t plucky binutils \
    && apt-get install -y gcc-15-multilib g++-15-multilib \
    && update-alternatives --install /usr/bin/cc cc /usr/bin/clang-21 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-21 100 \
    && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-15 100 \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]