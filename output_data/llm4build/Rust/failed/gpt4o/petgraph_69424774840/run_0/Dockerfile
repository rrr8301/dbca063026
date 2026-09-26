FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables for CI
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Rust beta
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain beta
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-nextest
RUN cargo install cargo-nextest

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser