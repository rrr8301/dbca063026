FROM golang:1.26-alpine

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    wget \
    build-base \
    ca-certificates \
    postgresql-client \
    mysql-client \
    npm \
    bash

# Install Node.js LTS
RUN npm install -g n && n lts

# Install nancy (dependency checker) with retry logic
RUN /bin/bash -c 'for i in {1..3}; do \
    curl -sSfL https://raw.githubusercontent.com/sonatype-nexus-community/nancy/main/install.sh | bash -s -- -b /usr/local/bin && break || \
    ([ $i -lt 3 ] && echo "Retry $i failed, retrying..." && sleep 5) || exit 1; \
    done'

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Download Go dependencies
RUN go mod download

# Install npm dependencies
RUN npm install

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]