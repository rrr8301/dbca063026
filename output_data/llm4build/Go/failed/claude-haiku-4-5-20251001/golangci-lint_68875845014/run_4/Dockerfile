FROM golang:1.26-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    build-base \
    ca-certificates \
    bash

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create run.sh with proper line endings and execute permissions
RUN printf '#!/bin/bash\n\nset -e\n\n# Navigate to workspace\ncd /workspace\n\n# Download Go module dependencies\ngo mod download\n\n# Run tests using the exact command from the YAML\nmake test\n' > /run.sh && chmod +x /run.sh

ENTRYPOINT ["/run.sh"]