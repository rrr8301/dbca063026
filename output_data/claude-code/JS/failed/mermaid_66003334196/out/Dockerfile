FROM node:22.14.0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY repo/ /app/

RUN npm install -g pnpm@10.30.3

RUN pnpm install --frozen-lockfile
ENV CYPRESS_CACHE_FOLDER=/app/.cache/Cypress

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
