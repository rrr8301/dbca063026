FROM node:24-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install required packages
RUN apk add --no-cache \
    git \
    jq \
    curl \
    build-base \
    python3 \
    make \
    bash

# Install pnpm
RUN npm install -g pnpm

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install project dependencies
RUN pnpm install

# Compile TypeScript
RUN pnpm run compile

# Copy and set entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]