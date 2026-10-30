FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Create non-root user
RUN useradd -m testuser

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set execute permissions for run.sh before switching to non-root user
RUN chmod +x /workspace/run.sh

# Configure git
RUN git config --global --add safe.directory '*'

# Switch to non-root user
USER testuser

# Install Rust as the testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Ensure Rust environment is available for the user
RUN rustup default nightly

# Ensure Rust environment is available for the user
RUN rustup component add clippy

# Set the entrypoint to run.sh
ENTRYPOINT ["/workspace/run.sh"]