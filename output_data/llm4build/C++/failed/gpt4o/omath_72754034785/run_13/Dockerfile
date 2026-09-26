# Use an official Ubuntu as a parent image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV VCPKG_ROOT=/vcpkg

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git build-essential cmake ninja-build \
    zip unzip curl pkg-config ca-certificates \
    wget software-properties-common && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-21 main" && \
    apt-get update && \
    apt-get install -y clang-21 lld-21 libc++-21-dev libc++abi-21-dev llvm-21 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-21 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-21 100 && \
    update-alternatives --install /usr/bin/lld lld /usr/bin/lld-21 100 && \
    rm -rf /var/lib/apt/lists/*

# Clone and bootstrap vcpkg
RUN git clone https://github.com/microsoft/vcpkg $VCPKG_ROOT && \
    $VCPKG_ROOT/bootstrap-vcpkg.sh

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Run the build and tests
CMD ["bash", "-c", "cmake --preset linux-release-vcpkg && cmake --build cmake-build/build/linux-release-vcpkg --target unit_tests omath && ./out/Release/unit_tests"]