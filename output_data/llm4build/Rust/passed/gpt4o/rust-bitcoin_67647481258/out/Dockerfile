# Use the official Rust image as the base image
FROM rust:latest

# Set the working directory inside the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . .

# Make the run.sh script executable
RUN chmod +x run.sh

# Run the run.sh script
CMD ["./run.sh"]