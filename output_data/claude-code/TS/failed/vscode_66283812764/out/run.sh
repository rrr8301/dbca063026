#!/usr/bin/env bash
set -e

cd /app

# Start xvfb
service xvfb start || true
export DISPLAY=:10

# Ensure electron and playwright are properly installed
npm exec -- npm-run-all2 -lp "electron x64" "playwright-install" || true

# Run unit tests (Electron)
echo "Running Electron unit tests..."
ELECTRON_ENABLE_LOGGING=1 .build/electron/Code test/unit/electron/index.js --crash-reporter-directory=/app/.build/crashes --tfs "Unit Tests" || {
    echo "FINAL_STATUS = FAIL"
    exit 1
}

# Run node.js tests
echo "Running Node.js tests..."
npm run test-node || {
    echo "FINAL_STATUS = FAIL"
    exit 1
}

echo "FINAL_STATUS = SUCCESS"
