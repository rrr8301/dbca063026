FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    musl-tools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install rustfmt and clippy
RUN rustup component add rustfmt clippy

# Install protoc (v33.1)
RUN curl -L https://github.com/protocolbuffers/protobuf/releases/download/v33.1/protoc-33.1-linux-x86_64.zip -o /tmp/protoc.zip && \
    unzip /tmp/protoc.zip -d /usr/local && \
    rm /tmp/protoc.zip

# Install flatc (v25.9.23)
RUN curl -L https://github.com/google/flatbuffers/releases/download/v25.9.23/Linux.flatc.binary -o /usr/local/bin/flatc && \
    chmod +x /usr/local/bin/flatc

# Install cargo-nextest
RUN cargo install cargo-nextest --locked

# Set environment variables
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=1
ENV CARGO_BUILD_JOBS=2

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set entrypoint
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

ENTRYPOINT ["/usr/local/bin/run.sh"]