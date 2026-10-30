# Use a pre-built Python image with Python 3.14
FROM python:3.14-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    libhdf5-dev \
    git \
    curl \
    wget \
    make \
    cmake \
    ninja-build \
    g++ \
    clang \
    cargo \
    dnsutils && \  # Corrected the line continuation
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Attempt to install uv using the astral-sh/setup-uv GitHub Action equivalent in Docker
RUN curl -sSL https://install.astral.sh | bash || true

# Ensure uv is in the PATH
ENV PATH="/root/.local/bin:${PATH}"

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]