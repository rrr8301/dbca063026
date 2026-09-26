FROM golang:1.23-bookworm

# Set timezone to avoid interactive prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    make \
    build-essential \
    curl \
    wget \
    ca-certificates \
    sudo \
    libipmctl5 \
    libipmctl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set project-specific environment variables
ENV GOLANG_VERSION=1.23 \
    DEBIAN_VERSION=bookworm

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Make all shell scripts executable
RUN chmod +x /workspace/build/integration-in-docker.sh && \
    chmod +x /workspace/build/config/libipmctl.sh

# Copy and set run.sh as entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]