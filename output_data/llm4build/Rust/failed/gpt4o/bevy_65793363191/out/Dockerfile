# Use the official Rust image as a parent image
FROM rust:latest

# Set the working directory inside the container
WORKDIR /usr/src/myapp

# Copy the current directory contents into the container at /usr/src/myapp
COPY . .

# Ensure the run.sh script is executable
RUN chmod +x run.sh

# Install necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libwayland-dev \
    libasound2-dev \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

# Build the Rust project
RUN cargo build --release

# Run the tests
CMD ["./run.sh"]