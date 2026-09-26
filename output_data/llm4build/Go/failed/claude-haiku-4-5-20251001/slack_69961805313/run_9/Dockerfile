FROM golang:1.26-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    ca-certificates \
    build-base

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create and set run.sh as entrypoint
RUN cat > /workspace/run.sh << 'EOF'
#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Navigate to workspace
cd /workspace

# Download Go module dependencies
echo "Downloading Go dependencies..."
go mod download

# Run tests with verbose output and race detector
echo "Running tests..."
go test -v -race ./...

echo "All tests completed successfully!"
EOF

RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]