#!/usr/bin/env bash

# Start xvfb (virtual display)
export DISPLAY=:99
Xvfb :99 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!

# Wait for xvfb to start
sleep 2

# Configure Chrome to use our wrapper script which adds --no-sandbox
export CHROME_BIN=/usr/local/bin/chrome-wrapper
export CHROMIUM_BIN=/usr/local/bin/chrome-wrapper

cd /app

npm run test:selector-native
TEST_RESULT=$?

# Kill xvfb
kill $XVFB_PID 2>/dev/null || true

if [ $TEST_RESULT -eq 0 ]; then
  echo "FINAL_STATUS = SUCCESS"
else
  echo "FINAL_STATUS = FAIL"
fi

exit $TEST_RESULT
