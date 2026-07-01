FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    sudo \
    cmake \
    ninja-build \
    g++ \
    make \
    curl \
    wget \
    libssl-dev  # Add OpenSSL development libraries

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Make run.sh executable
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]