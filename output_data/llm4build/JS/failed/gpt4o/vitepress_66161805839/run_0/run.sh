#!/bin/bash

# Clone the repository (simulating actions/checkout)
git clone <repository-url> /app
cd /app

# Install dependencies
pnpm install

# Run Playwright installation
pnpm playwright install chromium

# Run checks
pnpm check