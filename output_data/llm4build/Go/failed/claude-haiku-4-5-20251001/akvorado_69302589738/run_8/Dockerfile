FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    make \
    jq \
    zip \
    build-essential \
    ca-certificates \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22 (required for Vite 8.0.1+)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm

# Install Go (use a stable version that's available)
RUN curl -fsSL https://go.dev/dl/go1.21.13.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Fix permissions for all executable scripts in the repository
RUN chmod -R +x ./bin/ 2>/dev/null || true && \
    chmod -R +x ./common/schema/*.sh 2>/dev/null || true && \
    find . -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null || true

# Clean npm cache and node_modules to avoid stale bindings
RUN npm cache clean --force && \
    rm -rf node_modules package-lock.json && \
    rm -rf console/frontend/node_modules console/frontend/package-lock.json

# Copy and set run.sh as entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]