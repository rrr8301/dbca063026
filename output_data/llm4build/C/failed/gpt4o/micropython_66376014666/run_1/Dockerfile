FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    cmake \
    ninja-build \
    g++ \
    make \
    clang \
    pkg-config \
    python3.11 \
    python3.11-venv \
    python3.11-dev

# Set up work directory
WORKDIR /app

# Copy the repository into the container
COPY . .

# Ensure scripts have executable permissions
RUN chmod +x /app/run.sh && \
    chmod +x tools/ci.sh && \
    chmod +x tests/run-tests.py

# Set the entrypoint to run.sh
ENTRYPOINT ["/app/run.sh"]