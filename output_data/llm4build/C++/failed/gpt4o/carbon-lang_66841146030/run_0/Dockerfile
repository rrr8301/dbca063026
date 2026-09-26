FROM ubuntu:22.04

# Set timezone to avoid tzdata prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    clang \
    clang++ \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    && rm -rf /var/lib/apt/lists/*

# Install bazelisk
RUN wget -qO- https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-amd64 > /usr/local/bin/bazelisk && \
    chmod +x /usr/local/bin/bazelisk

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]