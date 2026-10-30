FROM node:22-alpine

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install build dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    build-base \
    python3 \
    make \
    dos2unix

# Install pnpm globally
RUN npm install -g pnpm@10.6.1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Convert line endings and set permissions for run.sh
RUN dos2unix /workspace/run.sh ; \
    chmod +x /workspace/run.sh ; \
    cat /workspace/run.sh | head -1

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]