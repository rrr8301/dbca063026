#!/bin/bash
set -e

# Enable error handling but continue on test failures
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

echo "=========================================="
echo "🚀 Starting virtualenv test suite"
echo "=========================================="

# Fetch upstream tags for versioning
echo "📥 Fetching upstream tags..."
git fetch --force --tags https://github.com/pypa/virtualenv.git || true

# Install uv if not already available
echo "📦 Ensuring uv is available..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Update PATH to ensure uv is found
export PATH="/root/.local/bin:/root/.cargo/bin:$PATH"

# Verify uv is available
if ! command -v uv &> /dev/null; then
    echo "❌ Failed to locate uv after installation"
    exit 1
fi

# Bootstrap pip for Python 3.10 if needed
echo "🐍 Bootstrapping Python 3.10..."
python3.10 -m ensurepip --upgrade || {
    echo "⚠️  Warning: ensurepip failed, attempting alternative approach..."
    curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3.10
}

# Install tox with Python 3.10 (matching the test environment)
echo "🐍 Installing tox with Python 3.10..."
uv tool install --no-managed-python --python 3.10 "tox>=4.32" --with tox-uv --with . || {
    echo "⚠️  Warning: uv tool install had issues, attempting alternative approach..."
    python3.10 -m pip install --upgrade pip setuptools wheel
    python3.10 -m pip install "tox>=4.32" tox-uv
}

# Set environment variables for testing
export TOXENV=3.10
export PYTEST_ADDOPTS="-vv --durations=20"
export CI_RUN="yes"
export DIFF_AGAINST=HEAD

echo "🧬 Environment variables set:"
echo "  TOXENV=$TOXENV"
echo "  PYTEST_ADDOPTS=$PYTEST_ADDOPTS"
echo "  CI_RUN=$CI_RUN"
echo "  DIFF_AGAINST=$DIFF_AGAINST"

# Setup test suite (install dependencies without running tests)
echo "🏗️  Setting up test suite..."
tox run -vvvv --notest --skip-missing-interpreters false || {
    echo "⚠️  Warning: tox setup had issues, continuing..."
    TEST_FAILED=1
}

# Run test suite
echo "🏃 Running test suite..."
tox run --skip-pkg-install || {
    echo "⚠️  Test suite execution completed with errors"
    TEST_FAILED=1
}

echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    echo "=========================================="
    exit 0
else
    echo "❌ Some tests failed or had issues"
    echo "=========================================="
    exit 1
fi