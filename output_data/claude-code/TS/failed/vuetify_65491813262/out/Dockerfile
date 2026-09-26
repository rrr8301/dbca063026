FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies including Chromium runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    build-essential \
    python3 \
    libglib2.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxext6 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libgbm1 \
    libnss3 \
    libasound2 \
    libnspr4 \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v24.11.1 using nvm
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
ENV NODE_PATH=$NVM_DIR/versions/node/v24.11.1/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/v24.11.1/bin:$PATH
RUN . $NVM_DIR/nvm.sh && nvm install 24.11.1 && nvm use 24.11.1

# Install pnpm
RUN npm install -g pnpm@latest

WORKDIR /app

# Copy repo
COPY repo/ /app/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Install playwright chromium
RUN pnpm exec playwright install chromium

# Copy and run test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
