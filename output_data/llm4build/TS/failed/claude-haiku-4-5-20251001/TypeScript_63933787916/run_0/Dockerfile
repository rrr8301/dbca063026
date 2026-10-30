FROM node:14-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    echo "America/Los_Angeles" > /etc/timezone

# Install build tools and git
RUN apk add --no-cache \
    git \
    build-essential \
    python3 \
    make \
    g++ \
    curl

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install project dependencies
RUN npm ci

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]