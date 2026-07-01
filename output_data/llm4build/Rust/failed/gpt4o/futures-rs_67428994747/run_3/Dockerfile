FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser

# Ensure Rust environment is available for the user
RUN echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc

# Switch to the user's home directory to ensure the environment is set up correctly
USER testuser
WORKDIR /workspace

# Initialize Rust environment for the user
RUN /bin/bash -c "source $HOME/.cargo/env && rustup toolchain install nightly"

# Change ownership of the workspace and cargo directory
USER root
RUN chown -R testuser /workspace /root/.cargo
USER testuser