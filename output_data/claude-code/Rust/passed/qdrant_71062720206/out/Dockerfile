FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV PATH="/root/.cargo/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    clang-15 \
    lld-15 \
    protobuf-compiler \
    git \
    ca-certificates \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Rust stable
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Install mold linker
RUN apt-get update && apt-get install -y \
    mold \
    && rm -rf /var/lib/apt/lists/* && \
    ln -sf /usr/bin/mold /usr/local/bin/mold

# Install nextest
RUN /root/.cargo/bin/cargo install --locked cargo-nextest

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Create .cargo directory and configure mold for Linux
RUN mkdir -p /app/.cargo && \
    echo "[target.x86_64-unknown-linux-gnu]" >> /app/.cargo/config.toml && \
    echo "linker = \"clang\"" >> /app/.cargo/config.toml && \
    echo "rustflags = [\"-C\", \"link-arg=-fuse-ld=/usr/local/bin/mold\"]" >> /app/.cargo/config.toml

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
