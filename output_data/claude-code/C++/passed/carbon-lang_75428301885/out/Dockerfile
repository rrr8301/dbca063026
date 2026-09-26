FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    python3.10 \
    python3-pip \
    wget \
    xz-utils \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.10 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

# Download and install LLVM 19.1.7
RUN cd /tmp && \
    LLVM_RELEASE=19.1.7 && \
    LLVM_TARBALL_NAME=LLVM-$LLVM_RELEASE-Linux-X64 && \
    wget --quiet "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_RELEASE/$LLVM_TARBALL_NAME.tar.xz" && \
    mkdir -p /opt/llvm && \
    tar -xJf $LLVM_TARBALL_NAME.tar.xz --strip-components=1 -C /opt/llvm && \
    rm $LLVM_TARBALL_NAME.tar.xz && \
    /opt/llvm/bin/clang++ --version && \
    rm /opt/llvm/lib/{*.a,*.so,*.so.*} 2>/dev/null || true && \
    rm /opt/llvm/bin/{flang-*,mlir-*,clang-{scan-deps,check,repl},*-test,llvm-{lto*,reduce,bolt*,exegesis,jitlink},bugpoint,opt,llc} 2>/dev/null || true

# Add LLVM to PATH
ENV PATH="/opt/llvm/bin:${PATH}"

# Copy repo
COPY ./repo /app/

WORKDIR /app

# Set required environment variables
ENV BAZEL_USE_CPP_ONLY_TOOLCHAIN=1

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
