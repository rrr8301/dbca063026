# Dockerfile
FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Install pnpm
RUN npm install -g pnpm@10

# Install additional required packages
RUN npm install -g del-cli c8

# Create and set working directory
WORKDIR /app

# Copy repository contents
COPY . .

# Ensure all dependencies are installed
RUN pnpm install --no-frozen-lockfile || true

# Install missing TypeScript types
RUN pnpm add -D @types/node @types/commander @types/cross-spawn @types/ejs

# Add missing TypeScript types for 'interpret'
RUN pnpm add -D @types/interpret

# Create pnpm-workspace.yaml if workspaces are used
RUN if grep -q '"workspaces"' package.json; then echo "packages:\n  - 'packages/*'" > pnpm-workspace.yaml; fi

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]