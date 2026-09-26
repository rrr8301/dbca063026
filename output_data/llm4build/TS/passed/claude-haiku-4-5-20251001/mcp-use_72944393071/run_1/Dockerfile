FROM node:22-alpine

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install build dependencies
RUN apk add --no-cache \
    git \
    curl \
    build-base \
    python3 \
    make

# Install pnpm globally
RUN npm install -g pnpm@10.6.1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]