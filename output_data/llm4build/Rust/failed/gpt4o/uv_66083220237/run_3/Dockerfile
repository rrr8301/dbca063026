FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    gnome-keyring \
    btrfs-progs \
    curl \
    build-essential \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install mold
COPY scripts/install-mold.sh /scripts/install-mold.sh
RUN chmod +x /scripts/install-mold.sh && /scripts/install-mold.sh

# Install cargo-nextest with --locked
RUN cargo install --locked cargo-nextest

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy and set permissions for run.sh
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]