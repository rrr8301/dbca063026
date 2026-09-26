# Use the official Rust image as a parent image
FROM rust:latest

# Set the working directory inside the container
WORKDIR /usr/src/myapp

# Copy the current directory contents into the container at /usr/src/myapp
COPY . .

# Install just, a command runner for Rust
RUN cargo install just

# Make run.sh executable
RUN chmod +x ./run.sh

# Run the script
CMD ["./run.sh"]