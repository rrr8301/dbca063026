FROM node:14-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    ca-certificates \
    git \
    curl \
    build-base \
    python3 \
    dos2unix

# Verify Node.js and npm installation
RUN node --version && npm --version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create run.sh directly in container to avoid line ending issues
RUN bash -c 'cat > /workspace/run.sh << '"'"'EOF'"'"'
#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Install dependencies with TypeScript 4 (force to allow peer dependency conflicts)
npm install -D typescript@4 --force
npm install --ignore-scripts

# Install older cssnano for Node 14/16 compatibility
npm install -D --no-save cssnano@^6 --force

# Run tests with coverage and CI flag
npm run test:coverage -- --ci

echo "All tests completed successfully!"
EOF'

# Set executable permissions
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]