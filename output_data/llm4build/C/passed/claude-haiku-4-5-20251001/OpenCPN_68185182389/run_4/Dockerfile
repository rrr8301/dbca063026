FROM ubuntu:22.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    pkg-config \
    curl \
    wget \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository (assumes repo is available in build context)
COPY . /workspace/

# Make run.sh and all ci scripts executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh && \
    chmod +x /workspace/ci/*.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]