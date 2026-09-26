FROM golang:1.24-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    redis \
    build-base \
    curl \
    wget \
    ca-certificates \
    bash

# Set Go environment variables
ENV GOPATH="/root/go" \
    PATH="/root/go/bin:$PATH"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Pre-install Go tools
RUN go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1 && \
    go install golang.org/x/tools/cmd/goimports@v0.23.0 && \
    go install honnef.co/go/tools/cmd/staticcheck@v0.6.1 && \
    go install github.com/magefile/mage@latest

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]