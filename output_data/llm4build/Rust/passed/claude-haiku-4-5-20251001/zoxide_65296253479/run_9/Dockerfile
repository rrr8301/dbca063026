FROM ubuntu:24.04

# Set timezone non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    pkg-config \
    ca-certificates \
    xz-utils \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Nix with daemon mode - let the installer create the nixbld group
RUN mkdir -m 0755 /nix && \
    chown root /nix
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/root/.cargo/bin:${PATH}"

# Install just
RUN cargo install just --locked

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set environment variables for Rust
ENV CARGO_INCREMENTAL=0
ENV CARGO_TERM_COLOR=always

# Copy and set entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]