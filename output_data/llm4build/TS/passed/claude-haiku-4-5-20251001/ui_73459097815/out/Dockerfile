FROM ubuntu:24.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm v9.0.6
RUN npm install -g pnpm@9.0.6

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Set Bun in PATH
ENV PATH="/root/.bun/bin:$PATH"

# Set environment variables for the application
ENV NEXT_PUBLIC_APP_URL=http://localhost:4000
ENV NEXT_PUBLIC_V0_URL=https://v0.dev

# Create and set working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]