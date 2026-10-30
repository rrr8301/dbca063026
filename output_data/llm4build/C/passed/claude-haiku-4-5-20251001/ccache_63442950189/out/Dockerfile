FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables for the build
ENV CTEST_OUTPUT_ON_FAILURE=ON \
    VERBOSE=1 \
    CMAKE_GENERATOR=Ninja \
    CC=gcc-11 \
    CXX=g++-11 \
    CMAKE_PARAMS="-D CMAKE_BUILD_TYPE=CI -D DEPS=LOCAL"

# Install dependencies
RUN apt-get update && apt-get install -y \
    # Build tools
    build-essential \
    cmake \
    ninja-build \
    git \
    # Project dependencies
    elfutils \
    libhiredis-dev \
    libzstd-dev \
    python3 \
    redis-server \
    redis-tools \
    binutils \
    doctest-dev \
    libfmt-dev \
    libxxhash-dev \
    # GCC 11
    g++-11 \
    g++-11-multilib \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and make run script executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]