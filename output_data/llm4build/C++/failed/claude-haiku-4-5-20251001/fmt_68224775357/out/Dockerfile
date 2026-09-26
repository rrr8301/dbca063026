FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    cmake \
    clang-14 \
    locales-all \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Copy and prepare run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]