FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV REACT=18
ENV SKIP_SEMANTIC=1
ENV NODE_VERSION=24

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    git \
    python3 \
    make \
    g++ \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN npm install --legacy-peer-deps 2>&1 | tail -20

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
