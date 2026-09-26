FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
    build-essential \
    python3 \
    pkg-config \
    libssl-dev \
    libnss3 \
    libnspr4 \
    libegl1-mesa \
    libxkbcommon0 \
    libexpat1 \
    libglib2.0-0 \
    libdbus-1-3 \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxdamage1 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxcomposite1 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libatspi2.0-0 \
    libasound2 \
    libdrm2 \
    libgbm1 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 10.33.0
RUN npm install -g pnpm@10.33.0

# Create app directory
WORKDIR /app

# Copy repository
COPY repo/ /app/

# Install project dependencies with playwright browser download skipped
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
RUN pnpm install

# Install Playwright chromium browser
RUN pnpm playwright install chromium

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
