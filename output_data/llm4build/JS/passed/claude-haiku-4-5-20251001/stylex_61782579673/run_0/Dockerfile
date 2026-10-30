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
    python3

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Prepare yarn via corepack and install dependencies
RUN corepack prepare yarn@1.22.22 --activate && \
    yarn install --frozen-lockfile

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]