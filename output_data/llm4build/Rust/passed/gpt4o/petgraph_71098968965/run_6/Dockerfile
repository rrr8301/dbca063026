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
    && rm -rf /var/lib/apt/lists/*

# Install Rust and cargo-nextest as root
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain beta
ENV PATH="/root/.cargo/bin:${PATH}"
RUN /root/.cargo/bin/cargo install --locked cargo-nextest

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set up Rust environment for testuser
RUN /bin/bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain beta"
ENV PATH="/home/testuser/.cargo/bin:${PATH}"

# Install cargo-nextest for testuser
RUN /home/testuser/.cargo/bin/cargo install --locked cargo-nextest

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]