FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install base prerequisites
RUN apt-get update -y && apt-get install -y \
    wget \
    gpg \
    python3-dev \
    libpython3-dev \
    build-essential \
    ocl-icd-libopencl1 \
    cmake \
    make \
    git \
    pkg-config \
    ocl-icd-dev \
    ocl-icd-opencl-dev \
    libhwloc-dev \
    zlib1g-dev \
    libtbb-dev \
    libopenblas-dev \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install LLVM 21 from apt.llvm.org
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update -y && \
    apt-get install -y \
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

# Install libjpeg-turbo
RUN wget -q -O /tmp/libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb && \
    dpkg -i /tmp/libjpeg-turbo.deb && \
    rm /tmp/libjpeg-turbo.deb

# Install ONNX Runtime
RUN wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz && \
    mkdir -p /opt/onnx && \
    tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1 && \
    ln -s /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib && \
    ln -s /opt/onnx/lib /opt/onnx/lib64 && \
    mv /opt/onnx/include /opt/onnxruntime && \
    mkdir -p /opt/onnx/include && \
    mv /opt/onnxruntime /opt/onnx/include/ && \
    rm /tmp/onnx-runtime.tgz

# Install libxsmm
RUN mkdir -p /opt/source && \
    cd /opt/source && \
    git clone https://github.com/libxsmm/libxsmm.git && \
    cd libxsmm && \
    git checkout 50c67024876111d81e685e94939ccbf04ab464b9 && \
    echo "unstable-1.17.1" > version.txt && \
    make -j3 STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm

# Build PoCL
RUN mkdir -p /workspace/build && \
    cd /workspace/build && \
    export CMAKE_PREFIX_PATH="/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake" && \
    export PKG_CONFIG_PATH="/opt/xsmm/lib" && \
    BUILD_FLAGS="-O1 -march=native -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable" && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
    -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
    -DENABLE_ICD=1 \
    -DENABLE_HOST_CPU_DEVICES=1 \
    /workspace && \
    make -j$(nproc)

# Copy run script and fix line endings
COPY run.sh /workspace/run.sh
RUN sed -i 's/\r$//' /workspace/run.sh && \
    chmod +x /workspace/run.sh

# Set environment variables for testing
ENV POCL_CACHE_DIR=/tmp/pocl_cache
ENV CL_PLATFORM_NAME=Portable
ENV CL_DEVICE_TYPE=cpu

# Create cache directory
RUN mkdir -p $POCL_CACHE_DIR

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]