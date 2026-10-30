FROM golang:1.26-alpine

# Set timezone to Pacific Time noninteractively
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

# Copy run.sh script and ensure LF line endings
COPY run.sh /workspace/run.sh
RUN sed -i 's/\r$//' /workspace/run.sh && chmod +x /workspace/run.sh

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]