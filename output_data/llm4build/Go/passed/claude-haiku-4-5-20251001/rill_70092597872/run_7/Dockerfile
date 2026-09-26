FROM golang:1.24-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    build-base \
    ca-certificates \
    dos2unix

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN dos2unix /workspace/run.sh && \
    chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]