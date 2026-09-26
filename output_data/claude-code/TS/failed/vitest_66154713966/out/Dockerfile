FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PLAYWRIGHT_BROWSERS_PATH=/app/.cache/ms-playwright
ENV CI=true

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@10.31.0

RUN apt-get update && apt-get install -y \
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    xdg-utils \
    libgbm1 \
    libnss3 \
    libxss1 \
    libappindicator3-1 \
    libindicator7 \
    lsb-release \
    xvfb \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

RUN pnpm install

RUN pnpm run build

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
