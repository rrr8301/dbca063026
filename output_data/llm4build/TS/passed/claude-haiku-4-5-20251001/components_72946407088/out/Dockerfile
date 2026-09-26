FROM ubuntu:latest

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    python3-dev \
    ca-certificates \
    apt-transport-https \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (using NodeSource repository for latest LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Install Bazel 8.6.0
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | apt-key add - && \
    echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list && \
    apt-get update && apt-get install -y --no-install-recommends bazel-8.6.0 && \
    ln -s /usr/bin/bazel-8.6.0 /usr/bin/bazel && \
    rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]