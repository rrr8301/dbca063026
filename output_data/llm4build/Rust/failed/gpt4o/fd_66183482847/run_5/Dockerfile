# Use the official Rust image as a parent image
FROM rust:latest

# Set the working directory inside the container
WORKDIR /usr/src/myapp

# Copy the current directory contents into the container at /usr/src/myapp
COPY . .

# Make the run.sh script executable
RUN chmod +x ./run.sh

# Set environment variables if needed
ENV TARGET=x86_64-unknown-linux-musl

# Run the run.sh script
CMD ["./run.sh"]