FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    git \
    build-essential \
    python3 \
    libc6 \
    libgcc1 \
    libstdc++6 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxcb1 \
    libgdk-pixbuf-2.0-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libharfbuzz0b \
    libfreetype6 \
    libfontconfig1 \
    libuuid1 \
    libmount1 \
    libdbus-1-3 \
    libglib2.0-0 \
    libgtk-3-0 \
    libstdc++6 \
    libglib2.0-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 10.28.2
RUN npm install -g pnpm@10.28.2

# Set working directory
WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install @antfu/ni globally
RUN npm install -g @antfu/ni

# Install project dependencies
RUN pnpm install

# Install Playwright browsers and dependencies
RUN pnpm exec playwright install --with-deps chromium webkit

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
