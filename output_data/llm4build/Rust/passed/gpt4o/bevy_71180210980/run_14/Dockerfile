# Use the official Rust image as the base image
FROM rust:latest

# Install necessary system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libwayland-dev \
    libasound2-dev \
    libudev-dev \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the Cargo.toml file
COPY ./Cargo.toml ./

# Copy the Cargo.lock file if it exists
COPY ./Cargo.lock ./ || echo "Cargo.lock not found, continuing without it."

# Build the dependencies to cache them
RUN cargo build --release --locked || echo "Cargo.lock not used, continuing with build."

# Copy the source code
COPY ./src ./src

# Build the Rust project
RUN cargo build --release

# Ensure the executable is in the expected location
RUN ls -l ./target/release/

# Command to run the executable
# Replace `my_rust_app` with the actual name of the executable if different
CMD ["./target/release/my_rust_app"]