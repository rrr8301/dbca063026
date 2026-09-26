FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTFLAGS="-D warnings"
ENV RUSTDOCFLAGS="-D warnings"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    git \
    git-lfs \
    libxcb-render0-dev \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxkbcommon-dev \
    libssl-dev \
    libgtk-3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Initialize git-lfs
RUN git lfs install

# Install Rust 1.92.0
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.92.0
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Initialize git-lfs in the copied repo
RUN cd /app && git lfs pull

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
