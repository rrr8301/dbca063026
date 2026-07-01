#!/usr/bin/env bash
set -e

cd /app

# Set up display for Xvfb
export DISPLAY=:10

# Start Xvfb in background
Xvfb :10 -screen 0 1024x768x24 > /tmp/xvfb.log 2>&1 &
XVFB_PID=$!
sleep 2

# Allow unprivileged user namespaces for Chromium's namespace sandbox
sysctl -w kernel.apparmor_restrict_unprivileged_userns=0 || true

# Set fontconfig workaround
export FONTCONFIG_FILE=/tmp/fonts-minimal.conf
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

# Rebuild fontconfig cache
rm -rf /var/cache/fontconfig 2>/dev/null || true
rm -rf ~/.cache/fontconfig 2>/dev/null || true
fc-cache -f -v 2>&1 | tail -5 || true

echo "=== Running unit tests (Electron) ==="
./scripts/test.sh --tfs "Unit Tests" || TEST_STATUS_ELECTRON=$?

echo ""
echo "=== Running unit tests (node.js) ==="
npm run test-node || TEST_STATUS_NODE=$?

echo ""
echo "=== Running integration tests (Electron) ==="
./scripts/test-integration.sh --tfs "Integration Tests" || TEST_STATUS_INTEGRATION=$?

echo ""
echo "=== Running smoke tests (Electron) ==="
npm run smoketest-no-compile -- --tracing || TEST_STATUS_SMOKE=$?

# Kill Xvfb
kill $XVFB_PID 2>/dev/null || true

# Check if all tests passed
if [[ -z "$TEST_STATUS_ELECTRON" && -z "$TEST_STATUS_NODE" && -z "$TEST_STATUS_INTEGRATION" && -z "$TEST_STATUS_SMOKE" ]]; then
  echo ""
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo ""
  echo "Some tests failed:"
  [[ -n "$TEST_STATUS_ELECTRON" ]] && echo "  - Electron unit tests: FAILED"
  [[ -n "$TEST_STATUS_NODE" ]] && echo "  - Node.js unit tests: FAILED"
  [[ -n "$TEST_STATUS_INTEGRATION" ]] && echo "  - Integration tests: FAILED"
  [[ -n "$TEST_STATUS_SMOKE" ]] && echo "  - Smoke tests: FAILED"
  echo "FINAL_STATUS = FAIL"
  exit 1
fi
