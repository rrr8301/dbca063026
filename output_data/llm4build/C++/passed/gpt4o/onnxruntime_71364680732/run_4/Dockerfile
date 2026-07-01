# Use an appropriate base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    python3.14 \
    python3-pip \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install Python dependencies
RUN python3.14 -m pip install --upgrade pip && \
    python3.14 -m pip install -r requirements-dev.txt

# Make the run script executable
RUN chmod +x run.sh

# Define the entry point
ENTRYPOINT ["./run.sh"]