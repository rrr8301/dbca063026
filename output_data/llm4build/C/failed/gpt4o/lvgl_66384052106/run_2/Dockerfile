FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    sudo \
    curl \
    wget \
    cmake \
    ninja-build \
    g++ \
    make \
    clang \
    cargo \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure scripts have execution permissions
RUN chmod +x /app/scripts/*.sh

# Copy and set permissions for run.sh
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]