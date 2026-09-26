# Use an appropriate base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    ninja-build \
    git \
    curl \
    wget \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.13
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.13 \
    python3.13-venv \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.13
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.13

# Install a newer version of CMake
RUN apt-get update && apt-get install -y \
    cmake-data \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the project files into the container
COPY . .

# Install Python dependencies
RUN python3.13 -m pip install --upgrade pip && \
    python3.13 -m pip install -r requirements-dev.txt

# Make the run script executable
RUN chmod +x run.sh

# Define the entry point
ENTRYPOINT ["./run.sh"]