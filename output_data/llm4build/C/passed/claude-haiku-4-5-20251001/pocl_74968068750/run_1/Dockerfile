FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base dependencies
RUN apt-get update -y && apt-get install -y \
    wget \
    gpg \
    python3-dev \
    libpython3-dev \
    build-essential \
    ocl-icd-libopencl1 \
    ocl-icd-dev \
    ocl-icd-opencl-dev \
    cmake \
    make \
    git \
    pkg-config \
    libhwloc-dev \
    zlib1g-dev \
    libtbb-dev \
    libopenblas-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install LLVM 21 from apt.llvm.org
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update -y && apt-get install -y \
    libclang-cpp21-dev \
    llvm-21-dev \
    libclang-21-dev \
    clang-21 \
    llvm-21 \
    mlir-21-tools \
    libllvmlibc-21-dev \
    libpolly-21-dev \
    spirv-tools \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]