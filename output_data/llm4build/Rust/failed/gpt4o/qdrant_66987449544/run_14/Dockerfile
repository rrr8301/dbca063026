# Use the official Rust image as a parent image
FROM rust:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    clang \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# Install mold
RUN curl -L https://github.com/rui314/mold/releases/download/v1.0.1/mold-1.0.1-x86_64-linux.tar.gz -o mold.tar.gz && \
    tar xzf mold.tar.gz && \
    cp mold-1.0.1/bin/mold /usr/local/bin/ && \
    rm -rf mold.tar.gz mold-1.0.1

# Set the working directory
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Run the run.sh script
CMD ["./run.sh"]