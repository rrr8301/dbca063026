FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VCPKG_ROOT=/app/vcpkg

# Install basic toolchain and LLVM 21
RUN apt-get update && apt-get install -y \
    wget curl git ca-certificates build-essential ninja-build \
    zip unzip pkg-config && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    echo "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && apt-get install -y \
    clang-21 lld-21 libc++-21-dev libc++abi-21-dev llvm-21 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-21 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install cmake 3.29+
RUN apt-get update && apt-get install -y \
    wget ca-certificates && \
    wget -qO /tmp/cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6-linux-x86_64.tar.gz && \
    tar xzf /tmp/cmake.tar.gz -C /usr/local --strip-components=1 && \
    rm /tmp/cmake.tar.gz && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the repo
COPY repo /app/

# Set up vcpkg
RUN git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT" && \
    cd "$VCPKG_ROOT" && \
    ./bootstrap-vcpkg.sh

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
