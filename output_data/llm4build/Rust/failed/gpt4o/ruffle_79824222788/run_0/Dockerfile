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
    libasound2-dev \
    mesa-vulkan-drivers \
    libudev-dev \
    libfontconfig-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable && \
    . $HOME/.cargo/env && \
    rustup component add rustfmt

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository
COPY --chown=testuser:testuser . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install cargo nextest
RUN . $HOME/.cargo/env && cargo install cargo-nextest

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]