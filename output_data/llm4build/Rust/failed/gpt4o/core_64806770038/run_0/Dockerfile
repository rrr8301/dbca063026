# Use Ubuntu as the base image
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    cmake \
    make \
    gcc \
    pkg-config \
    libssl-dev

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set Rust version
ENV RUST_VERSION=1.93.0
RUN rustup toolchain install --profile minimal $RUST_VERSION
RUN rustup override set $RUST_VERSION

# Create work directory
WORKDIR /app

# Copy the repository
COPY . .

# Install nextest
RUN cargo install cargo-nextest

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]