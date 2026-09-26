FROM ubuntu:24.04

# Set timezone non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    ninja-build \
    build-essential \
    gcc-14 \
    g++-14 \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and prepare run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]