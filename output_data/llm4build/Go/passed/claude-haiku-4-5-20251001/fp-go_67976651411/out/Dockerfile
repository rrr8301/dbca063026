FROM golang:1.24-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages including build essentials for cgo
RUN apk add --no-cache \
    git \
    ca-certificates \
    bash \
    gcc \
    musl-dev

# Enable CGO
ENV CGO_ENABLED=1

# Create working directory
WORKDIR /workspace

# Copy all project files (go.mod, go.sum, source code, etc.)
COPY . /workspace/

# Copy run.sh script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]