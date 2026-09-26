#!/bin/bash
set -e

# Source nvm setup
export NVM_DIR="/root/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

cd /app

# Set up git for testing
git config --global core.autocrlf false
git config --global user.name "test-user"
git config --global user.email "test@example.com"

# Fetch origin/main for the branch test filtering
git remote set-branches --add origin main 2>/dev/null || true
git fetch origin main --depth=1 2>/dev/null || true

echo "=== Compiling artifacts ==="
pnpm run compile-only 2>&1 | head -50 || true

echo ""
echo "=== Running ci:test-branch ==="
# Run the test command
pnpm run ci:test-branch || {
    echo ""
    echo "=========================================="
    echo "FINAL_STATUS = FAIL"
    echo "=========================================="
    exit 1
}

# Print success status
echo ""
echo "=========================================="
echo "FINAL_STATUS = SUCCESS"
echo "=========================================="
