# Use the official Rust image as a parent image
FROM rust:latest

# Set the working directory inside the container
WORKDIR /usr/src/myapp

# Copy the current directory contents into the container at /usr/src/myapp
COPY . .

# Install any additional dependencies if needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Add any additional packages here
    && rm -rf /var/lib/apt/lists/*

# Build the Rust project
RUN cargo build --release

# Run the tests
CMD ["./run.sh"]