#!/usr/bin/env bash
set -e

# Start virtual display
Xvfb :99 -ac -screen 0 1280x1024x24 &
XVFB_PID=$!
export DISPLAY=:99

# Give Xvfb time to start
sleep 2

echo "========== Running Lint =========="
npm run lint

echo "========== Running Unit Tests =========="
npm run citest.unit

# Clean up Xvfb
kill $XVFB_PID 2>/dev/null || true

echo "========== All Tests Passed =========="
echo "FINAL_STATUS = SUCCESS"
