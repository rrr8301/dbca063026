FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    clang \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Protoc
RUN apt-get update && apt-get install -y protobuf-compiler

# Install mold
RUN apt-get update && apt-get install -y build-essential cmake
RUN git clone https://github.com/rui314/mold.git /tmp/mold \
    && cd /tmp/mold \
    && git checkout v1.0.1 \
    && make -j$(nproc) install \
    && rm -rf /tmp/mold

# Install nextest
RUN cargo install cargo-nextest

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]