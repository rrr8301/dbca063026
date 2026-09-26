FROM golang:1.26-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Set Go module mode
ENV GO111MODULE=on

# Install additional dependencies
RUN apk add --no-cache \
    git \
    curl \
    ca-certificates \
    build-base

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint with explicit line ending conversion
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh || sed -i 's/\r$//' /workspace/run.sh && \
    chmod +x /workspace/run.sh

ENTRYPOINT ["/bin/sh", "/workspace/run.sh"]