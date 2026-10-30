FROM ubuntu:24.04

# Set timezone non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV HOME="/root"
ENV RUSTUP_HOME="${HOME}/.rustup"
ENV CARGO_HOME="${HOME}/.cargo"
ENV PATH="${HOME}/.cargo/bin:${PATH}"

# Install Rust toolchain with proper shell execution
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y --default-toolchain stable && \
    chmod -R a+w "${CARGO_HOME}" && \
    ls -la "${CARGO_HOME}/bin/" && \
    "${CARGO_HOME}/bin/rustc" --version && \
    "${CARGO_HOME}/bin/cargo" --version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]