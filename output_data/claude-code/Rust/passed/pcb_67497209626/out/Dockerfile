FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV CARGO_INCREMENTAL=0
ENV CARGO_PROFILE_TEST_DEBUG=0
ENV RUST_LOG=debug
ENV RUST_BACKTRACE=full

WORKDIR /app

# Install dependencies (Ubuntu)
RUN apt-get update && \
    apt-get install -y curl build-essential pkg-config libssl-dev git && \
    rm -rf /var/lib/apt/lists/*

# Copy repository
COPY repo/ /app/

# Install Rust (stable)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable && \
    /root/.cargo/bin/rustup component add rustfmt clippy

ENV PATH="/root/.cargo/bin:${PATH}"

# Install nextest
RUN /root/.cargo/bin/cargo install --locked cargo-nextest --version "0.9.*"

# Run tests
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
