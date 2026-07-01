FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3 \
    libc6 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxi6 \
    libxinerama1 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libxkbcommon0 \
    libpango-1.0-0 \
    libcairo2 \
    libdrm2 \
    libgbm1 \
    libnss3 \
    libgconf-2-4 \
    libappindicator1 \
    libappindicator3-1 \
    fonts-dejavu \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@10.33.0

WORKDIR /app

COPY repo/ /app/

ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

RUN pnpm install

RUN pnpm playwright install chromium

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
