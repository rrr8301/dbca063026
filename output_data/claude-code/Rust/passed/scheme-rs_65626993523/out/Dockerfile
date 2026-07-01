FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always

# Install system dependencies including Rust and LLVM
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    wget \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add LLVM repository
RUN curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-18 main" | tee /etc/apt/sources.list.d/llvm-18.list && \
    apt-get update

# Install LLVM packages
RUN apt-get install -y \
    libllvm18 \
    llvm-18 \
    llvm-18-dev \
    libpolly-18-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Add cargo to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install additional Rust components
RUN rustup component add clippy rustfmt

WORKDIR /app
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
