# Dockerfile
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-setuptools \
    python3-venv \
    git \
    make \
    curl \
    wget \
    ca-certificates

# Install Go 1.21 (latest stable version as of October 2023)
RUN wget https://go.dev/dl/go1.21.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.linux-amd64.tar.gz && \
    rm go1.21.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Set up Python virtual environment and install packages
RUN python3 -m venv /app/venv && \
    /app/venv/bin/pip install -U pip wheel pytest setuptools

# Ensure tests.sh is executable
RUN chmod +x ./tests.sh

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]