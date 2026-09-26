FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y \
    --default-toolchain stable \
    --profile minimal

# Set Rust environment variables
ENV PATH="/root/.cargo/bin:${PATH}" \
    CARGO_TERM_COLOR=always \
    CARGO_INCREMENTAL=0 \
    RUST_BACKTRACE=1

# Verify Rust installation
RUN rustc --version --verbose && cargo --version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Make all shell scripts executable
RUN find .github -name "*.sh" -type f -exec chmod +x {} \;

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]