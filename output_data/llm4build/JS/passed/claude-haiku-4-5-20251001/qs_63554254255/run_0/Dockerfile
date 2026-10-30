FROM node:20-alpine

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install build tools and git
RUN apk add --no-cache \
    git \
    curl \
    build-base \
    python3

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install npm dependencies
RUN npm ci

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]