FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies and Rust
RUN apt-get update -y && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust using rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Add i386 architecture
RUN dpkg --add-architecture i386

# Install 32-bit compilation dependencies
RUN apt-get update -y && apt-get install -y \
    gcc-multilib \
    g++-multilib \
    libc6-dev-i386 \
    lib32stdc++-13-dev \
    && rm -rf /var/lib/apt/lists/*

# Install i686 target for Rust
RUN rustup target add i686-unknown-linux-gnu

# Copy the repository
WORKDIR /app
COPY repo/ /app/

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
