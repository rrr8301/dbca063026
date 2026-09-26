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
    build-essential \
    libssl-dev \
    pkg-config \
    mold

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust tools separately to handle potential issues
RUN /root/.cargo/bin/cargo install cargo-insta uv
RUN /root/.cargo/bin/cargo install --locked cargo-nextest

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
COPY . /workspace
RUN chown -R testuser /workspace
RUN git config --global --add safe.directory '*'

# Switch to non-root user and set up Rust environment
USER testuser
ENV PATH="/home/testuser/.cargo/bin:${PATH}"
RUN echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc

# Ensure Rust environment is set up for testuser
USER root
RUN chmod +x /root/.cargo/bin/rustup-init
RUN /root/.cargo/bin/rustup-init -y --no-modify-path
USER testuser
RUN /home/testuser/.cargo/bin/rustup toolchain install stable
RUN /home/testuser/.cargo/bin/rustup default stable

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]