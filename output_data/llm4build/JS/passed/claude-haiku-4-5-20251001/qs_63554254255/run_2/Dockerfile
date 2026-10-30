FROM node:20-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install build tools and git
RUN apk add --no-cache \
    git \
    curl \
    build-base \
    python3

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install npm dependencies
RUN npm install

# Create and set run.sh as entrypoint
RUN echo '#!/bin/sh' > /workspace/run.sh && \
    echo '' >> /workspace/run.sh && \
    echo 'set -e' >> /workspace/run.sh && \
    echo '' >> /workspace/run.sh && \
    echo '# Print Node and npm versions for debugging' >> /workspace/run.sh && \
    echo 'echo "Node version: $(node --version)"' >> /workspace/run.sh && \
    echo 'echo "npm version: $(npm --version)"' >> /workspace/run.sh && \
    echo '' >> /workspace/run.sh && \
    echo '# Run the test suite' >> /workspace/run.sh && \
    echo 'echo "Running tests..."' >> /workspace/run.sh && \
    echo 'npm run tests-only' >> /workspace/run.sh && \
    echo '' >> /workspace/run.sh && \
    echo 'echo "All tests completed successfully!"' >> /workspace/run.sh && \
    chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]