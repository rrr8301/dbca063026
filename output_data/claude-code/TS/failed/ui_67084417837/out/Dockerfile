FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NEXT_PUBLIC_APP_URL=http://localhost:4000
ENV NEXT_PUBLIC_V0_URL=https://v0.dev

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    unzip \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 9.0.6
RUN npm install -g pnpm@9.0.6

# Install Bun
RUN npm install -g bun

WORKDIR /app

COPY repo/ /app/

RUN pnpm install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
