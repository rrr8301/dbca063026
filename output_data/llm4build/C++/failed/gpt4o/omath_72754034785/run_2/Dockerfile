FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add LLVM repository and install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common wget && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt_llvm_org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-21 main" && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git build-essential cmake ninja-build \
    zip unzip curl pkg-config ca-certificates \
    clang-21 lld-21 libc++-21-dev libc++abi-21-dev \
    llvm-21 && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]