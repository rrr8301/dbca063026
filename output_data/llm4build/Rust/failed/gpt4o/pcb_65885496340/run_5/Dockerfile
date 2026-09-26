# Use an official Ubuntu as a parent image
FROM ubuntu:22.04

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl build-essential pkg-config libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-nextest
RUN cargo install cargo-nextest

# Copy the current directory contents into the container at /app
COPY . .

# Ensure the script is executable
RUN chmod +x /app/run.sh

# Run the application
CMD ["./run.sh"]