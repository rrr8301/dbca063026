# Use the official Rust image as the base image
FROM rust:latest

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libwayland-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Build the Rust project
RUN cargo build --release

# Command to run the executable
CMD ["./target/release/my_rust_app"]