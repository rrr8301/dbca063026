FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget gpg python3-dev libpython3-dev build-essential \
    ocl-icd-libopencl1 cmake make git pkg-config \
    ocl-icd-dev ocl-icd-opencl-dev \
    libhwloc-dev zlib1g-dev libtbb-dev

RUN export LLVM_VERSION=21 && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-${LLVM_VERSION} main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update && apt-get install -y \
    libclang-cpp21-dev llvm-21-dev libclang-21-dev clang-21 llvm-21 \
    mlir-21-tools libllvmlibc-21-dev libpolly-21-dev spirv-tools

RUN apt-get install -y libopenblas-dev && \
    wget -q -O /tmp/libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb && \
    dpkg -i /tmp/libjpeg-turbo.deb && \
    wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz && \
    mkdir -p /opt/onnx && tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1 && \
    ln -s /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib && \
    ln -s /opt/onnx/lib /opt/onnx/lib64 && \
    mv /opt/onnx/include /opt/onnxruntime && mkdir -p /opt/onnx/include && mv /opt/onnxruntime /opt/onnx/include/

RUN mkdir -p /opt/source && \
    cd /opt/source && git clone https://github.com/libxsmm/libxsmm.git && \
    cd libxsmm && git checkout 50c67024876111d81e685e94939ccbf04ab464b9 && \
    echo "unstable-1.17.1" > version.txt && \
    make -j3 STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm

WORKDIR /app
COPY repo/ /app/

RUN mkdir -p /app/build && \
    cd /app/build && \
    export CMAKE_PREFIX_PATH=/opt/libjpeg-turbo/lib/cmake:/opt/onnx/lib/cmake && \
    export PKG_CONFIG_PATH=/opt/xsmm/lib && \
    cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_C_FLAGS_RELWITHDEBINFO="-O2 -march=x86-64-v2 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable" \
    -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-O2 -march=x86-64-v2 -Wall -Wextra -Wno-unused-parameter -Wno-unused-variable" \
    -DWITH_LLVM_CONFIG=/usr/bin/llvm-config-21 \
    -DENABLE_ICD=1 -DENABLE_HOST_CPU_DEVICES=1 -DLLC_HOST_CPU=haswell \
    /app

RUN cd /app/build && make -j$(nproc)

RUN mkdir -p /tmp/GH_POCL_CACHE

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
