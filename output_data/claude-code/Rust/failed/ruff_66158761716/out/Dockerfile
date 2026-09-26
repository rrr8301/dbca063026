FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_INCREMENTAL=0
ENV CARGO_NET_RETRY=10
ENV CARGO_TERM_COLOR=always
ENV RUSTUP_MAX_RETRIES=10
ENV NEXTEST_PROFILE=ci
ENV MDTEST_EXTERNAL=1
ENV CARGO_PROFILE_DEV_DEBUG=line-tables-only

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    ca-certificates \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

ENV PATH="/root/.cargo/bin:${PATH}"

# Install additional tools
RUN rustup component add rustfmt clippy
RUN cargo install cargo-nextest --locked
RUN cargo install cargo-insta --locked
RUN cargo binstall mold -y --force --disable-strategies crate-meta-data || true

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Copy repository
WORKDIR /app
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
