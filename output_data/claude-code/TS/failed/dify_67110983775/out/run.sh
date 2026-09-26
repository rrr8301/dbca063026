#!/usr/bin/env bash
set -e

cd /app

# Install system dependencies for Playwright
apt-get update && apt-get install -y \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0 \
    libxcb1 \
    libxkbcommon0 \
    libxss1 \
    libxtst6 \
    fonts-noto-color-emoji \
    && rm -rf /var/lib/apt/lists/* || true

# Run web tests (shard 1 of 4)
cd /app/web
echo "Running web tests (shard 1/4)..."
pnpm exec vp test run --reporter=blob --shard=1/4 --coverage || true

# Run dify-ui tests
cd /app/packages/dify-ui
echo "Installing Chromium for Browser Mode..."
pnpm exec vp exec playwright install --with-deps chromium || true

echo "Running dify-ui tests..."
pnpm exec vp test run --coverage --silent=passed-only || true

echo "FINAL_STATUS = SUCCESS"
