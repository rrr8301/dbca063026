FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    cmake \
    clang \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Install mise tools
RUN /root/.cargo/bin/cargo install mise

# Copy Rust environment to a shared location
RUN mkdir -p /opt/rust && cp -r /root/.cargo /opt/rust/cargo

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Ensure Rust environment is available for testuser
RUN echo 'source /opt/rust/cargo/env' >> /home/testuser/.bashrc

# Set PATH for testuser
ENV PATH="/opt/rust/cargo/bin:${PATH}"

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]