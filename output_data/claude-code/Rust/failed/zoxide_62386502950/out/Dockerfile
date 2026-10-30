FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_TERM_COLOR=always
ENV CARGO_INCREMENTAL=0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    ca-certificates \
    pkg-config \
    libssl-dev \
    zlib1g-dev \
    clang \
    nodejs \
    npm \
    mandoc \
    shellcheck \
    yamllint \
    && rm -rf /var/lib/apt/lists/*

# Install shfmt using apt package
RUN apt-get update && apt-get install -y \
    shfmt \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (stable and nightly)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install rust tools
RUN rustup toolchain install nightly && \
    cargo install cargo-nextest cargo-msrv cargo-udeps --locked

# Install markdownlint
RUN npm install -g markdownlint-cli

# Install just
RUN cargo install just --locked

# Install nixfmt (we'll need to check if it's available)
# For now, we'll skip nixfmt or install it separately

WORKDIR /app
COPY repo/ /app/

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
