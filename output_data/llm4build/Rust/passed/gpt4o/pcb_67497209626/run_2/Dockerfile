# Use a base image that matches your environment needs
FROM ubuntu:22.04

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y curl build-essential pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy your application code
COPY . .

# Run your application or tests
CMD ["cargo", "test", "--workspace", "--locked"]