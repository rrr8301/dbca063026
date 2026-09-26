FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Add LLVM 21 repository and install toolchain
RUN apt-get update && apt-get install -y \
    wget gnupg software-properties-common && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" && \
    add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu plucky main universe" && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
        git build-essential cmake ninja-build \
        zip unzip curl pkg-config ca-certificates \
        clang-21 lld-21 libc++-21-dev libc++abi-21-dev \
        binutils \
        gcc-15-multilib g++-15-multilib && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-21 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-15 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-15 100 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

# Set up vcpkg
ENV VCPKG_ROOT=/app/vcpkg
RUN git clone https://github.com/microsoft/vcpkg "$VCPKG_ROOT" && \
    cd "$VCPKG_ROOT" && \
    ./bootstrap-vcpkg.sh

# Configure
RUN cmake --preset linux-release-vcpkg-x86 \
    -DVCPKG_INSTALL_OPTIONS="--allow-unsupported" \
    -DOMATH_BUILD_TESTS=ON \
    -DOMATH_BUILD_BENCHMARK=OFF \
    -DOMATH_ENABLE_COVERAGE=OFF \
    -DVCPKG_MANIFEST_FEATURES="imgui;avx2;tests;lua"

# Build
RUN cmake --build cmake-build/build/linux-release-vcpkg-x86 --target unit_tests omath

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
