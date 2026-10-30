FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt update -y && \
    apt install -y wget gpg python3-dev libpython3-dev build-essential ocl-icd-libopencl1 cmake make git pkg-config ocl-icd-libopencl1 ocl-icd-dev ocl-icd-opencl-dev libhwloc-dev zlib1g-dev libtbb-dev libopenblas-dev clang llvm spirv-tools

# Install LLVM 21 and MLIR
RUN export LLVM_VERSION=21 && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-snapshot.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/llvm-snapshot.gpg] http://apt.llvm.org/noble/ llvm-toolchain-noble-${LLVM_VERSION} main" >/etc/apt/sources.list.d/llvm.list && \
    apt update -y && \
    apt install -y libclang-cpp${LLVM_VERSION}-dev llvm-${LLVM_VERSION}-dev libclang-${LLVM_VERSION}-dev clang-${LLVM_VERSION} llvm-${LLVM_VERSION} mlir-${LLVM_VERSION}-tools libllvmlibc-${LLVM_VERSION}-dev libpolly-${LLVM_VERSION}-dev

# Install XSMM, ONNX, and libjpeg-turbo
RUN apt install -y libopenblas-dev && \
    wget -q -O libjpeg-turbo.deb https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/libjpeg-turbo-official_3.0.4_amd64.deb && \
    dpkg -i libjpeg-turbo.deb && \
    wget -q -O /tmp/onnx-runtime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.19.2/onnxruntime-linux-x64-1.19.2.tgz && \
    mkdir /opt/onnx && tar -xf /tmp/onnx-runtime.tgz -C /opt/onnx --strip-components=1 && \
    ln -s /opt/libjpeg-turbo/lib64 /opt/libjpeg-turbo/lib && \
    ln -s /opt/onnx/lib /opt/onnx/lib64 && \
    mv /opt/onnx/include /opt/onnxruntime && mkdir /opt/onnx/include && mv /opt/onnxruntime /opt/onnx/include/ && \
    bash -c 'mkdir /opt/source && cd /opt/source && git clone https://github.com/libxsmm/libxsmm.git && cd libxsmm && git checkout 50c67024876111d81e685e94939ccbf04ab464b9 && echo "unstable-1.17.1" > version.txt && make -j3 STATIC=0 FORTRAN=0 AVX=2 install DESTDIR=/opt/xsmm'

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]