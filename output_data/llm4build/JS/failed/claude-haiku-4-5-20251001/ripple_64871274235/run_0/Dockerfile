FROM node:20-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install build tools and git
RUN apk add --no-cache \
    git \
    curl \
    build-essential \
    python3 \
    make \
    g++

# Install pnpm globally
RUN npm install -g pnpm

# Create work directory
WORKDIR /workspace

# Copy repository (assumes repo is available in build context)
COPY . .

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]