FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Create non-root user
RUN useradd -m testuser

# Install Rust for the non-root user
USER testuser
WORKDIR /home/testuser
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Ensure the Rust environment is initialized
RUN echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc

# Switch back to root to copy files
USER root

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Make run.sh executable
RUN chmod +x /workspace/run.sh

# Change ownership of the workspace to the non-root user
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Switch to bash shell to ensure .bashrc is sourced
SHELL ["/bin/bash", "-c"]

# Source the Rust environment in the entrypoint
ENTRYPOINT ["/bin/bash", "-c", "source /home/testuser/.cargo/env && exec /workspace/run.sh"]