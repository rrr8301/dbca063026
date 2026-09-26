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
    libssl-dev \
    libffi-dev \
    ca-certificates \
    python3 \
    python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Install Rust toolchain for root user
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

# Install Rust toolchain for non-root user
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Ensure Rust environment is set up for the non-root user
RUN /bin/bash -c "source /home/testuser/.cargo/env && rustup default stable"

# Make sure run.sh is executable
RUN chmod +x /workspace/run.sh

# Entry point
CMD ["/bin/bash", "/workspace/run.sh"]