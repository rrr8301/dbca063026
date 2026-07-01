FROM golang:1.26-alpine AS builder

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Set UTF-8 locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    ca-certificates \
    build-base \
    gcc \
    make \
    bash

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git safe directory to avoid ownership errors
RUN git config --global --add safe.directory '*'

# Create non-root user and transfer ownership
RUN adduser -D testuser && \
    chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]