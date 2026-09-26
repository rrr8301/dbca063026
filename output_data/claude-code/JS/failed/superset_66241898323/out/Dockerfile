# Dockerfile for Superset frontend Jest tests (shard 4)
FROM node:20-trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV BUILD_TRANSLATIONS=false
ENV DEV_MODE=false
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV BUILD_CMD=build

WORKDIR /app

# Copy docker utilities
COPY repo/docker/ /app/docker/

# Install system dependencies required for node-gyp
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3 \
    zstd \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Run the frontend memory monitoring script
RUN bash /app/docker/frontend-mem-nag.sh

WORKDIR /app/superset-frontend

# Create necessary folders
RUN mkdir -p /app/superset/static/assets \
             /app/superset/translations

# Copy package files
COPY repo/superset-frontend/package.json /app/superset-frontend/
COPY repo/superset-frontend/package-lock.json /app/superset-frontend/

# Install dependencies
RUN npm ci

# Copy the rest of the frontend code
COPY repo/superset-frontend /app/superset-frontend

# Copy translation files
COPY repo/superset/translations /app/superset/translations

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
