FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LLVM_PATH=/home/llvm
ENV PATH=${LLVM_PATH}/bin:${PATH}

# Install system dependencies and Python
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    ca-certificates \
    build-essential \
    python3.10 \
    python3.10-dev \
    python3-pip \
    libxml2 \
    libxml2-dev \
    zlib1g \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install LLVM 19.1.7
RUN cd /home && \
    LLVM_RELEASE=19.1.7 && \
    LLVM_TARBALL_NAME=LLVM-$LLVM_RELEASE-Linux-X64 && \
    wget --show-progress=off "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_RELEASE/$LLVM_TARBALL_NAME.tar.xz" && \
    mkdir -p $LLVM_PATH && \
    tar -xJf $LLVM_TARBALL_NAME.tar.xz --strip-components=1 -C $LLVM_PATH && \
    rm $LLVM_TARBALL_NAME.tar.xz && \
    echo "*** Cleaning LLVM directory" && \
    rm -f $LLVM_PATH/lib/{*.a,*.so,*.so.*} && \
    rm -f $LLVM_PATH/bin/{flang-*,mlir-*,clang-{scan-deps,check,repl},*-test,llvm-{lto*,reduce,bolt*,exegesis,jitlink},bugpoint,opt,llc}

# Copy the repository
WORKDIR /app
COPY repo/ /app/

# Install Python dependencies if needed
RUN python3.10 -m pip install --upgrade pip

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
