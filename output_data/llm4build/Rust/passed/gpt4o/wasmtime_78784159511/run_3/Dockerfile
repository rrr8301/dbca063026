FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    python3 \
    python3-pip \
    util-linux \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
RUN rustup set profile minimal
RUN rustup target add wasm32-wasip1 wasm32-unknown-unknown wasm32-wasip2

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
COPY . /workspace
RUN chown -R testuser /workspace
RUN git config --global --add safe.directory '*'
USER testuser

# Install Python dependencies
RUN pip3 install --no-cache-dir -r tests/wasi_testsuite/wasi-common/test-runner/requirements.txt

# Ensure Rust environment is activated for the user
RUN echo 'source $HOME/.cargo/env' >> /home/testuser/.bashrc