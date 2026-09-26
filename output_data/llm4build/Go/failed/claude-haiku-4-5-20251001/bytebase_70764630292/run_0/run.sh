#!/bin/bash

set -e

# Track test failures but continue execution
TEST_FAILED=0

echo "=========================================="
echo "Backend Tests - Go Test Suite"
echo "=========================================="

# Step 1: Verify go.mod is tidy
echo ""
echo "Step 1: Verifying go.mod is tidy..."
cd /workspace
go mod tidy
if ! git diff --exit-code; then
    echo "ERROR: go.mod is not tidy. Please run 'go mod tidy' and commit changes."
    TEST_FAILED=1
else
    echo "✓ go.mod is tidy"
fi

# Step 2: Install mongosh (Linux only)
echo ""
echo "Step 2: Installing mongosh (if needed)..."
if command -v mongosh &> /dev/null; then
    echo "✓ mongosh is already installed at $(which mongosh)"
    mongosh --version
else
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Installing mongosh v2.5.0 for Linux..."
        MONGOSH_VERSION="2.5.0"
        ARCH=$(uname -m)

        if [[ "$ARCH" == "x86_64" ]]; then
            ARCH="x64"
        elif [[ "$ARCH" == "aarch64" ]]; then
            ARCH="arm64"
        fi

        ARCHIVE="mongosh-${MONGOSH_VERSION}-linux-${ARCH}.tgz"
        DOWNLOAD_URL="https://downloads.mongodb.com/compass/${ARCHIVE}"

        WORK_DIR="${TMPDIR:-/tmp}"
        echo "Working directory: $WORK_DIR"
        cd "$WORK_DIR"

        echo "Downloading from ${DOWNLOAD_URL}"
        curl -fsSL "${DOWNLOAD_URL}" -o "${ARCHIVE}"
        echo "Download complete, extracting..."
        tar -xzf "${ARCHIVE}"

        mkdir -p "$HOME/.local/bin"
        EXTRACTED_DIR="mongosh-${MONGOSH_VERSION}-linux-${ARCH}"
        cp "${EXTRACTED_DIR}/bin/mongosh" "$HOME/.local/bin/mongosh"
        chmod +x "$HOME/.local/bin/mongosh"

        export PATH="$HOME/.local/bin:$PATH"

        rm -rf "${EXTRACTED_DIR}" "${ARCHIVE}"

        "$HOME/.local/bin/mongosh" --version
        echo "✓ mongosh v${MONGOSH_VERSION} installed successfully to $HOME/.local/bin"
    else
        echo "⚠ Non-Linux OS detected. Skipping mongosh installation."
        echo "Please ensure mongosh is installed manually on macOS runners."
    fi
fi

# Step 3: Run all tests
echo ""
echo "Step 3: Running Go tests..."
cd /workspace
if go test -p=8 -timeout 30m -ldflags "-w -s" -v ./backend/... 2>&1 | tee test.log; then
    echo "✓ All tests passed"
else
    echo "✗ Some tests failed"
    TEST_FAILED=1
fi

# Step 4: Pretty print test running times
echo ""
echo "Step 4: Test execution summary (sorted by duration)..."
if [ -f test.log ]; then
    echo "=========================================="
    echo "Test Duration Summary (descending order):"
    echo "=========================================="
    grep --color=never -e '--- PASS:' -e '--- FAIL:' test.log | sed 's/[:()]//g' | awk '{print $2,$3,$4}' | sort -t' ' -nk3 -r | awk '{sum += $3; print $1,$2,$3,sum"s"}' || true
    echo "=========================================="
else
    echo "⚠ test.log not found, skipping summary"
fi

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo ""
    echo "❌ Test suite completed with failures"
    exit 1
else
    echo ""
    echo "✅ Test suite completed successfully"
    exit 0
fi