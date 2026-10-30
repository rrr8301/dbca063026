FROM ubuntu:24.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tzdata \
    git \
    curl \
    ca-certificates \
    libasound2-dev \
    mesa-vulkan-drivers \
    libudev-dev \
    libfontconfig-dev \
    build-essential \
    pkg-config \
    libssl-dev && \  # Added libssl-dev for OpenSSL development files
    rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Install Rust toolchain as non-root user
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable && \
    /home/testuser/.cargo/bin/rustup component add rustfmt && \
    /home/testuser/.cargo/bin/rustup target add x86_64-unknown-linux-gnu

# Set up Rust environment for the non-root user
RUN echo 'export PATH=$PATH:/home/testuser/.cargo/bin' >> /home/testuser/.bashrc && \
    echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc

# Install cargo-nextest with --locked
RUN /home/testuser/.cargo/bin/cargo install --locked cargo-nextest --root /home/testuser/.cargo

# Copy the repository
COPY --chown=testuser:testuser . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]