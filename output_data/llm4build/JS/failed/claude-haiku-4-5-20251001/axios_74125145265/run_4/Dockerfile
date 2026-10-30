FROM node:14-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN apk add --no-cache tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# Install additional dependencies
RUN apk add --no-cache \
    bash \
    git \
    curl \
    build-base \
    ca-certificates

# Create work directory
WORKDIR /workspace

# Copy run.sh and fix line endings before making executable
COPY run.sh /workspace/run.sh
RUN sed -i 's/\r$//' /workspace/run.sh && \
    chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]