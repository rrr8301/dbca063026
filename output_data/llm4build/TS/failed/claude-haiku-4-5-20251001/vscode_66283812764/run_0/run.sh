#!/bin/bash
set -e

# Set environment variables
export VSCODE_QUALITY='oss'
export ARTIFACT_NAME='electron'
export NPM_ARCH='x64'
export VSCODE_ARCH='x64'
export DISPLAY=':10'
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Start X server (Xvfb)
echo "Starting Xvfb..."
Xvfb :10 -screen 0 1024x768x24 > /dev/null 2>&1 &
XVFB_PID=$!
sleep 2

# Trap to ensure Xvfb is killed on exit
trap "kill $XVFB_PID 2>/dev/null || true" EXIT

# Read Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
echo "Node.js version from .nvmrc: $NODE_VERSION"

# Setup environment
echo "Setting up environment..."
source ./build/azure-pipelines/linux/setup-env.sh

# Install build dependencies (with retry logic)
echo "Installing build dependencies..."
cd build
for i in {1..5}; do
    if npm ci; then
        echo "Build dependencies installed successfully"
        break
    fi
    if [ $i -eq 5 ]; then
        echo "Npm install failed too many times" >&2
        exit 1
    fi
    echo "Npm install failed $i, trying again..."
    sleep 2
done
cd ..

# Install dependencies (with retry logic)
echo "Installing dependencies..."
for i in {1..5}; do
    if npm ci; then
        echo "Dependencies installed successfully"
        break
    fi
    if [ $i -eq 5 ]; then
        echo "Npm install failed too many times" >&2
        exit 1
    fi
    echo "Npm install failed $i, trying again..."
    sleep 2
done

# Create .build folder
mkdir -p .build

# Download built-in extensions
echo "Downloading built-in extensions..."
node build/lib/builtInExtensions.ts

# Transpile client and extensions
echo "Transpiling client and extensions..."
npm run gulp transpile-client-esbuild transpile-extensions

# Download Electron and Playwright (with retry logic)
echo "Downloading Electron and Playwright..."
for i in {1..3}; do
    if npm exec -- npm-run-all2 -lp "electron $VSCODE_ARCH" "playwright-install"; then
        echo "Download successful on attempt $i"
        break
    fi
    if [ $i -eq 3 ]; then
        echo "Download failed after 3 attempts" >&2
        exit 1
    fi
    echo "Download failed on attempt $i, retrying..."
    sleep 5
done

# Run unit tests (Electron)
echo "Running unit tests (Electron)..."
./scripts/test.sh --tfs "Unit Tests" || TEST_FAILED=1

# Run unit tests (node.js)
echo "Running unit tests (node.js)..."
npm run test-node || TEST_FAILED=1

# Build integration tests
echo "Building integration tests..."
npm run gulp \
    compile-extension:configuration-editing \
    compile-extension:css-language-features-server \
    compile-extension:emmet \
    compile-extension:git \
    compile-extension:github-authentication \
    compile-extension:html-language-features-server \
    compile-extension:ipynb \
    compile-extension:notebook-renderers \
    compile-extension:json-language-features-server \
    compile-extension:markdown-language-features \
    compile-extension-media \
    compile-extension:microsoft-authentication \
    compile-extension:typescript-language-features \
    compile-extension:vscode-api-tests \
    compile-extension:vscode-colorize-tests \
    compile-extension:vscode-colorize-perf-tests \
    compile-extension:vscode-test-resolver

# Run integration tests (Electron)
echo "Running integration tests (Electron)..."
./scripts/test-integration.sh --tfs "Integration Tests" || TEST_FAILED=1

# Compile smoke tests
echo "Compiling smoke tests..."
cd test/smoke
npm run compile
cd ../..

# Compile extensions for smoke tests
echo "Compiling extensions for smoke tests..."
npm run gulp compile-extension-media

# Diagnostics before smoke test run
echo "Diagnostics before smoke test run..."
ps -ef || true
cat /proc/sys/fs/inotify/max_user_watches || true
lsof | wc -l || true

# Run smoke tests (Electron)
echo "Running smoke tests (Electron)..."
npm run smoketest-no-compile -- --tracing || TEST_FAILED=1

# Diagnostics after smoke test run
echo "Diagnostics after smoke test run..."
ps -ef || true
cat /proc/sys/fs/inotify/max_user_watches || true
lsof | wc -l || true

# Exit with failure if any test failed
if [ "${TEST_FAILED}" = "1" ]; then
    echo "Some tests failed"
    exit 1
fi

echo "All tests completed successfully"
exit 0