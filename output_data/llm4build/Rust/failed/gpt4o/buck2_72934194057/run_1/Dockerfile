FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    opam libzstd-dev python3-pip erlang git \
    cmake ninja-build g++ make clang curl wget && \
    rm -rf /var/lib/apt/lists/*

# Install uv and conan
RUN pip3 install uv && uv tool install conan==1.*

# Install Go
RUN wget https://golang.org/dl/go1.22.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz && \
    rm go1.22.0.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Set up Rust
COPY rust-toolchain /tmp/rust-toolchain
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . "$HOME/.cargo/env" && \
    rustup toolchain install $(cat /tmp/rust-toolchain | grep -oP '(?<=channel = ").*(?=")') && \
    rustup component add clippy

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and set as entrypoint
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]