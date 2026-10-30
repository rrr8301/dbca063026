FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    gcc \
    g++ \
    cmake \
    ninja-build \
    curl \
    wget \
    clang \
    cargo \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository contents
COPY . .

# Modify posix-deps-apt.sh to remove sudo and fix package name
RUN sed -i 's/sudo //g' ./.github/workflows/posix-deps-apt.sh && \
    sed -i 's/libmpdec-dev/libmpdec3-dev/g' ./.github/workflows/posix-deps-apt.sh

# Install project dependencies
RUN ./.github/workflows/posix-deps-apt.sh

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]