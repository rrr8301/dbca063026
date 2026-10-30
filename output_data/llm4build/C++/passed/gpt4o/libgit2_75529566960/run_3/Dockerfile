FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    gcc \
    g++ \
    make \
    libssl-dev \
    libssh2-1-dev \
    valgrind \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /app

# Copy the entire repository to the container
COPY . .

# Ensure the ci directory is copied correctly
# Adjust the path based on the actual structure
# If source/ci does not exist, remove this line or correct the path
# COPY source/ci /app/source/ci

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]