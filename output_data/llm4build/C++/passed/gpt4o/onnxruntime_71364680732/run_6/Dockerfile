# Use an appropriate base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    cmake \
    ninja-build \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Add deadsnakes PPA for Python 3.14 (simulated)
# Since Python 3.14 is not available, we will use Python 3.13 as a placeholder
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
    python3.13 \
    python3.13-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.13 (simulating Python 3.14)
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.13

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