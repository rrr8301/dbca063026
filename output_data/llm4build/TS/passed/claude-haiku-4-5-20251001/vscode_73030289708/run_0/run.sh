#!/bin/bash

set -e

# Enable X server
echo "Starting X server..."
sudo service xvfb start || true
sleep 2

# Allow unprivileged user namespaces for Chromium's namespace sandbox
echo "Configuring kernel parameters..."
sudo sysctl -w kernel.apparmor_restrict_unprivileged_userns=0 || true

# Setup fontconfig workaround for expat CVEs
echo "Setting up fontconfig..."
EXPAT_VER=$(dpkg-query -W -f='${Version}' libexpat1 2>/dev/null || echo "0")
if ! dpkg --compare-versions "$EXPAT_VER" ge "2.7.5"; then
    echo "Applying fontconfig workaround for expat CVE..."
    cat > /tmp/fonts-minimal.conf << 'FONTCONFIG_EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <dir>/usr/share/fonts</dir>
  <dir>/usr/local/share/fonts</dir>
  <dir prefix="xdg">fonts</dir>
  <cachedir>/var/cache/fontconfig</cachedir>
  <cachedir prefix="xdg">fontconfig</cachedir>
  <match target="pattern">
    <test qual="any" name="family"><string>mono</string></test>
    <edit name="family" mode="assign" binding="same"><string>monospace</string></edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family"><string>sans serif</string></test>
    <edit name="family" mode="assign" binding="same"><string>sans-serif</string></edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family"><string>sans</string></test>
    <edit name="family" mode="assign" binding="same"><string>sans-serif</string></edit>
  </match>
  <match target="pattern">
    <test qual="any" name="family"><string>system ui</string></test>
    <edit name="family" mode="assign" binding="same"><string>system-ui</string></edit>
  </match>
  <alias>
    <family>monospace</family>
    <prefer><family>DejaVu Sans Mono</family></prefer>
  </alias>
  <alias>
    <family>sans-serif</family>
    <prefer><family>DejaVu Sans</family></prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer><family>DejaVu Serif</family></prefer>
  </alias>
  <match target="pattern">
    <test qual="all" name="family" compare="not_eq"><string>sans-serif</string></test>
    <test qual="all" name="family" compare="not_eq"><string>serif</string></test>
    <test qual="all" name="family" compare="not_eq"><string>monospace</string></test>
    <edit name="family" mode="append_last"><string>sans-serif</string></edit>
  </match>
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
  </match>
  <config>
    <rescan><int>0</int></rescan>
  </config>
</fontconfig>
FONTCONFIG_EOF
    export FONTCONFIG_FILE=/tmp/fonts-minimal.conf
fi

# Clear and rebuild font cache
rm -rf /var/cache/fontconfig ~/.cache/fontconfig 2>/dev/null || true
fc-cache -f -v 2>&1 | tail -5 || true

echo "Font configuration complete"

# Read Node.js version from .nvmrc
NODE_VERSION=$(cat .nvmrc)
echo "Node.js version from .nvmrc: $NODE_VERSION"

# Install build dependencies (with retries)
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

# Setup environment
echo "Setting up environment..."
source ./build/azure-pipelines/linux/setup-env.sh

# Install main dependencies (with retries)
echo "Installing main dependencies..."
for i in {1..5}; do
    if npm ci; then
        echo "Main dependencies installed successfully"
        break
    fi
    if [ $i -eq 5 ]; then
        echo "Npm install failed too many times" >&2
        exit 1
    fi
    echo "Npm install failed $i, trying again..."
    sleep 2
done

# Prepare node_modules cache key
echo "Preparing node_modules cache key..."
mkdir -p .build
node build/azure-pipelines/common/computeNodeModulesCacheKey.ts linux $VSCODE_ARCH $(node -p process.arch) > .build/packagelockhash

# Create node_modules archive
echo "Creating node_modules archive..."
node build/azure-pipelines/common/listNodeModules.ts .build/node_modules_list.txt
mkdir -p .build/node_modules_cache
tar -czf .build/node_modules_cache/cache.tgz --files-from .build/node_modules_list.txt

# Prepare built-in extensions cache key
echo "Preparing built-in extensions cache key..."
node build/azure-pipelines/common/computeBuiltInDepsCacheKey.ts > .build/builtindepshash

# Download built-in extensions
echo "Downloading built-in extensions..."
node build/lib/builtInExtensions.ts

# Transpile client and extensions
echo "Transpiling client and extensions..."
npm run gulp transpile-client-esbuild transpile-extensions

# Download Electron and Playwright (with retries)
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
TEST_FAILED=0
if ./scripts/test.sh --tfs "Unit Tests" || TEST_FAILED=1; then
    echo "Electron unit tests completed"
fi

# Run unit tests (Node.js)
echo "Running unit tests (Node.js)..."
if npm run test-node || TEST_FAILED=1; then
    echo "Node.js unit tests completed"
fi

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

# Compile Copilot extension
echo "Compiling Copilot extension..."
npm --prefix extensions/copilot run compile

# Run integration tests (Electron)
echo "Running integration tests (Electron)..."
if ./scripts/test-integration.sh --tfs "Integration Tests" || TEST_FAILED=1; then
    echo "Electron integration tests completed"
fi

# Compile smoke tests
echo "Compiling smoke tests..."
cd test/smoke
npm run compile
cd ../..

# Compile extensions for smoke tests
echo "Compiling extensions for smoke tests..."
npm run gulp compile-extension-media

# Diagnostics before smoke test run
echo "=== Diagnostics before smoke test run ==="
ps -ef || true
cat /proc/sys/fs/inotify/max_user_watches || true
lsof | wc -l || true

# Run smoke tests (Electron)
echo "Running smoke tests (Electron)..."
if npm run smoketest-no-compile -- --tracing || TEST_FAILED=1; then
    echo "Electron smoke tests completed"
fi

# Diagnostics after smoke test run
echo "=== Diagnostics after smoke test run ==="
ps -ef || true
cat /proc/sys/fs/inotify/max_user_watches || true
lsof | wc -l || true

# Exit with failure if any test failed
if [ $TEST_FAILED -eq 1 ]; then
    echo "One or more test suites failed"
    exit 1
fi

echo "All tests completed successfully!"
exit 0