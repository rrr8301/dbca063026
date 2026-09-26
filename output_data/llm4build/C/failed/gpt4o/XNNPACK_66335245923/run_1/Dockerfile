FROM ghcr.io/google/xnnpack/standard:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    gcc-9 \
    g++-9 \
    cmake \
    ninja-build \
    make \
    bazel \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Set timezone to Pacific Time
RUN ln -snf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && echo "America/Los_Angeles" > /etc/timezone

# Create work directory
WORKDIR /workspace

# Copy repository contents
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]