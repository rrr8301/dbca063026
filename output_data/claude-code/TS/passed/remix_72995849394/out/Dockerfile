FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CI=true
ENV GITHUB_ACTIONS=true

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24.x
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm install -g pnpm@10.32.1

# Install Playwright system dependencies
RUN apt-get update && apt-get install -y \
    libnss3 \
    libnspr4 \
    libdbus-1-3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxcb1 \
    libxkbcommon0 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    fonts-liberation \
    libappindicator3-1 \
    libgbm1 \
    libglib2.0-0 \
    libgl1-mesa-glx \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libxss1 \
    lsb-release \
    wget \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN pnpm install --frozen-lockfile

# Install Playwright browsers
RUN pnpm --filter @remix-run/component exec playwright install --with-deps

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
