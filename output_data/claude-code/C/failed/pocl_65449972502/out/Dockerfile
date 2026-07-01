FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LLVM_VERSION=21
ENV CCACHE_BASEDIR=/app
ENV CCACHE_DIR=/tmp/ccache
ENV CCACHE_COMPRESS=true
ENV CCACHE_COMPRESSLEVEL=1
ENV CCACHE_MAXSIZE=25000M
ENV CTEST_NO_TESTS_ACTION=error
ENV POCL_CACHE_DIR=/tmp/GH_POCL_CACHE
ENV CL_PLATFORM_NAME=Portable
ENV CL_DEVICE_TYPE=cpu

RUN apt update -y && \
    apt install -y wget gpg python3-dev libpython3-dev build-essential \
    ocl-icd-libopencl1 cmake make git pkg-config ocl-icd-dev \
    ocl-icd-opencl-dev libhwloc-dev zlib1g-dev libtbb-dev

RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-21 main" > /etc/apt/sources.list.d/llvm.list && \
    apt update -y && \
    apt install -y libclang-cpp21-dev llvm-21-dev \
    libclang-21-dev clang-21 llvm-21 \
    mlir-21-tools libllvmlibc-21-dev \
    libpolly-21-dev spirv-tools

RUN apt install -y libopenblas-dev && \
    wget -q -O /tmp/libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb && \
    dpkg -i /tmp/libjpeg-turbo.deb && \
    wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz && \
    mkdir -p /opt/onnx && tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1 && \
    ln -s /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib && \
    ln -s /opt/onnx/lib /opt/onnx/lib64 && \
    mv /opt/onnx/include /opt/onnxruntime && mkdir /opt/onnx/include && mv /opt/onnxruntime /opt/onnx/include/ && \
    bash -c 'mkdir -p /opt/source && cd /opt/source && git clone https://github.com/libxsmm/libxsmm.git && cd libxsmm && git checkout 50c67024876111d81e685e94939ccbf04ab464b9 && echo "unstable-1.17.1" > version.txt && make -j3 STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm'

WORKDIR /app

COPY repo/ /app/

RUN mkdir -p /app/build && \
    cd /app/build && \
    export CMAKE_PREFIX_PATH=/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake && \
    export PKG_CONFIG_PATH=/opt/xsmm/lib && \
    BUILD_FLAGS="-O1 -march=native -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable" && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    "-DCMAKE_C_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
    "-DCMAKE_CXX_FLAGS_RELWITHDEBINFO=$BUILD_FLAGS" \
    -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
    -DENABLE_ICD=1 -DENABLE_HOST_CPU_DEVICES=1 \
    /app && \
    cd /app/build && grep 'define HAVE_ONNXRT' config.h && \
    grep 'define HAVE_LIBJPEG_TURBO' config.h && \
    grep 'define HAVE_LIBXSMM' config.h && \
    make -j$(nproc)

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
