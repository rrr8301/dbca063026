FROM node:22-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install build dependencies
RUN apk add --no-cache \
    git \
    curl \
    build-base \
    python3 \
    dos2unix

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Convert line endings and set permissions for run script
RUN dos2unix /workspace/run.sh && \
    chmod +x /workspace/run.sh

# Prepare yarn via corepack and install dependencies
RUN corepack prepare yarn@1.22.22 --activate && \
    yarn install --frozen-lockfile

ENTRYPOINT ["/workspace/run.sh"]