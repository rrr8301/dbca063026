FROM ubuntu:24.04

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup as root (before switching users)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Create non-root user and set up Rust for them
RUN useradd -m testuser && \
    cp -r /root/.cargo /home/testuser/.cargo && \
    cp -r /root/.rustup /home/testuser/.rustup && \
    chown -R testuser:testuser /home/testuser/.cargo && \
    chown -R testuser:testuser /home/testuser/.rustup && \
    chown -R testuser:testuser /workspace

USER testuser

# Set Rust toolchain for the user
ENV PATH="/home/testuser/.cargo/bin:${PATH}"
ENV RUSTUP_HOME="/home/testuser/.rustup"
ENV CARGO_HOME="/home/testuser/.cargo"

# Ensure nightly is set as default for testuser
RUN rustup default nightly

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]