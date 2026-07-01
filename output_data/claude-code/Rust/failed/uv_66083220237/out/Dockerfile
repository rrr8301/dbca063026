FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    gnome-keyring \
    btrfs-progs \
    util-linux \
    python3 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:$PATH"

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Copy the repository
COPY repo/ /app/

WORKDIR /app

# Install mold linker
RUN ./scripts/install-mold.sh

# Copy run.sh
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
