FROM golang:1.24-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles

# Install required packages
RUN apk add --no-cache \
    git \
    ca-certificates \
    bash

# Create working directory
WORKDIR /workspace

# Copy run.sh script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]