FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Rust beta toolchain
RUN rustup toolchain install beta && rustup default beta

# Install cargo-nextest
RUN cargo install cargo-nextest --locked

# Create non-root user
RUN useradd -m testuser

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git to allow workspace directory (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Transfer ownership to non-root user
RUN chown -R testuser:testuser /workspace

# Install Rust for testuser by copying from root installation
RUN cp -r /root/.cargo /home/testuser/.cargo && \
    cp -r /root/.rustup /home/testuser/.rustup && \
    chown -R testuser:testuser /home/testuser/.cargo /home/testuser/.rustup

# Switch to non-root user
USER testuser

# Set PATH for testuser
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]