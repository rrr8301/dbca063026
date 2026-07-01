FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV RUST_BACKTRACE=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ca-certificates \
    pkg-config \
    libssl-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (stable first, then switch to nightly)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile=minimal --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Set nightly as override
RUN rustup override set nightly && rustup update nightly

WORKDIR /app
COPY repo/ /app/

# Remove rust-toolchain.toml to allow nightly to be used
RUN rm -f rust-toolchain.toml

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
