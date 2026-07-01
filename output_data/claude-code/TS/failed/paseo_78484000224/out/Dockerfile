FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ONNXRUNTIME_NODE_INSTALL=skip

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    ca-certificates \
    git \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN npm ci

RUN npx playwright install --with-deps chromium

RUN npm run build:app-deps

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
