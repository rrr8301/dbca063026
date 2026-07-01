FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    postgresql-client \
    mysql-client \
    npm \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js version from .nvmrc (will be determined at runtime)
# For now, use a recent LTS version; adjust if .nvmrc specifies otherwise
RUN npm install -g n && n lts

# Install golangci-lint with retry logic
RUN /bin/bash -c 'for i in {1..3}; do \
    curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | bash -s -- -b /usr/local/go/bin latest && break || \
    ([ $i -lt 3 ] && echo "Retry $i failed, retrying..." && sleep 5) || exit 1; \
    done'

# Install nancy (dependency checker) with retry logic
RUN /bin/bash -c 'for i in {1..3}; do \
    curl -sSfL https://raw.githubusercontent.com/sonatype-nexus-community/nancy/main/install.sh | bash -s -- -b /usr/local/bin v1.0.42 && break || \
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