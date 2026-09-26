FROM ubuntu:22.04

# Set environment variables
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    pkg-config \
    libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Ensure Rust environment is set up for the non-root user
RUN /bin/bash -c "source $HOME/.cargo/env && rustup default stable"

# Entry point
CMD ["bash", "/workspace/run.sh"]