FROM node:22-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN corepack enable && \
    corepack prepare pnpm@10.33.0 --activate

RUN pnpm install --frozen-lockfile

RUN node scripts/generate-domains-index.mjs

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
