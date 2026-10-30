#!/bin/bash

set -e

# Print Node.js and npm versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Navigate to workspace
cd /workspace

# Set Chromium binary path for headless testing
export CHROME_BIN=/usr/bin/chromium-browser
export CHROMEDRIVER_BIN=$(which chromedriver)

# Comprehensive Chrome flags for Docker container
export CHROME_FLAGS="--no-sandbox --disable-gpu --disable-dev-shm-usage --disable-software-rasterizer --disable-extensions --disable-setuid-sandbox --disable-web-resources --disable-sync --disable-default-apps --disable-plugins --disable-plugin-power-saver --disable-preconnect --disable-background-networking --disable-breakpad --disable-client-side-phishing-detection --disable-component-extensions-with-background-pages --disable-default-apps --disable-hang-monitor --disable-popup-blocking --disable-prompt-on-repost --disable-sync --enable-automation --no-first-run --password-store=basic --use-mock-keychain"

# Verify Chromium is available
if [ ! -f "$CHROME_BIN" ]; then
    echo "Error: Chromium binary not found at $CHROME_BIN"
    exit 1
fi

# Verify ChromeDriver is available
if [ -z "$CHROMEDRIVER_BIN" ] || [ ! -f "$CHROMEDRIVER_BIN" ]; then
    echo "Error: ChromeDriver binary not found"
    exit 1
fi

echo "Chromium binary found at: $CHROME_BIN"
echo "ChromeDriver binary found at: $CHROMEDRIVER_BIN"
echo "Chrome flags: $CHROME_FLAGS"

# Start dbus session daemon (user session, not system)
echo "Starting dbus session daemon..."
eval "$(dbus-launch --sh-syntax)"
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID
sleep 1

# Start Xvfb virtual display in the background
echo "Starting Xvfb virtual display..."
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!
export DISPLAY=:99

# Give Xvfb time to start
sleep 3

# Verify Xvfb is running
if ! kill -0 $XVFB_PID 2>/dev/null; then
    echo "Error: Xvfb failed to start"
    cat /tmp/xvfb.log
    exit 1
fi

echo "Xvfb started successfully with PID: $XVFB_PID"

# Set additional environment variables for Chrome
export DISPLAY=:99
export QT_QPA_PLATFORM=offscreen
export WEBDRIVER_CHROME_DRIVER=$CHROMEDRIVER_BIN

# Set Chrome-specific environment variables for headless operation
export CHROMIUM_FLAGS="$CHROME_FLAGS"
export CHROME_HEADLESS=true
export CHROME_HEADLESS_MODE=true

# Disable GPU and enable headless mode for Chromium
export CHROMIUM_HEADLESS=true

# Additional environment variables for better Chrome stability
export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

# Set environment variables for Selenium WebDriver
export CHROMEDRIVER_SKIP_DOWNLOAD=true
export CHROMEDRIVER_VERSION=$(chromedriver --version | awk '{print $NF}')

# Increase timeout for Chrome startup
export CHROMEDRIVER_TIMEOUT=30000

# Run the test:selector-native test suite
echo "Running test:selector-native..."
npm run test:selector-native

TEST_EXIT_CODE=$?

# Clean up processes
echo "Cleaning up..."
if [ -n "$XVFB_PID" ]; then
    kill $XVFB_PID 2>/dev/null || true
    wait $XVFB_PID 2>/dev/null || true
fi

if [ -n "$DBUS_SESSION_BUS_PID" ]; then
    kill $DBUS_SESSION_BUS_PID 2>/dev/null || true
    wait $DBUS_SESSION_BUS_PID 2>/dev/null || true
fi

if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "All tests completed successfully!"
else
    echo "Tests failed with exit code: $TEST_EXIT_CODE"
    exit $TEST_EXIT_CODE
fi