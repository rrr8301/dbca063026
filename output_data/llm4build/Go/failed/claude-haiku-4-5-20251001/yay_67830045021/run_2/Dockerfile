FROM ghcr.io/jguer/yay-builder:latest

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create and set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create run.sh inline to avoid file not found error
RUN cat > /run.sh << 'EOFSCRIPT'
#!/bin/bash
set -e

cd /workspace

echo "Running linting..."
export GOFLAGS="-buildvcs=false -tags=next"
/app/bin/golangci-lint run -v ./...

echo "Running build and tests..."
make test

echo "All checks passed!"
EOFSCRIPT

RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]