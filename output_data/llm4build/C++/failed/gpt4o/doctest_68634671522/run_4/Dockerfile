# Use an appropriate base image
FROM ubuntu:22.04

# Enable i386 architecture and install necessary packages
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    valgrind \
    libc6-dbg:i386 \
    python3 \
    clang-14 \
    libclang-14-dev \
    llvm-14-dev \
    g++-multilib

# Set the working directory
WORKDIR /workspace

# Copy the project files into the container
COPY . /workspace

# Set the entrypoint to the run.sh script
ENTRYPOINT ["/workspace/run.sh"]