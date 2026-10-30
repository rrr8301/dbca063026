FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  curl \
  wget \
  git \
  build-essential \
  python3 \
  ca-certificates \
  libglib2.0-0 \
  libx11-6 \
  libx11-xcb1 \
  libxcb1 \
  libxrandr2 \
  libpango-1.0-0 \
  libdbus-1-3 \
  libatk1.0-0 \
  libcups2 \
  libdrm2 \
  libgbm1 \
  libxss1 \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

RUN npm install -g pnpm@10.26.1

WORKDIR /app

COPY repo/ /app/

RUN pnpm install --frozen-lockfile

RUN pnpm exec playwright install chromium

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
