#!/bin/bash
set -e

echo "=========================================="
echo "Starting Dash Build & Test Pipeline"
echo "=========================================="

# Activate virtual environment
source /opt/venv/bin/activate

# Navigate to workspace
cd /workspace

echo ""
echo "=========================================="
echo "Step 1: Build Dash Package"
echo "=========================================="

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
npm ci

# Install Python build dependencies first (before running build scripts)
echo "Installing Python build dependencies..."
python -m pip install --upgrade pip
python -m pip install "setuptools<80.0.0"
python -m pip install build wheel

# Install development dependencies (includes coloredlogs and other build tools)
echo "Installing development dependencies..."
python -m pip install -e .[dev,ci]

# Build frontend
echo "Building Dash frontend..."
npm run build

# Build Dash sdist and wheel
echo "Building Dash sdist and wheel..."
python -m build --sdist --wheel
echo "Built packages:"
ls -lhR dist/

# Create packages directory and copy wheels
mkdir -p packages
cp dist/*.whl packages/

echo ""
echo "=========================================="
echo "Step 2: Lint & Unit Tests"
echo "=========================================="

# Install Dash packages from built wheels
echo "Installing Dash packages from wheels..."
python -m pip install --upgrade pip wheel
python -m pip install "setuptools<80.0.0"
find packages -name "dash-*.whl" -print -exec sh -c 'pip install "{}[dev,ci,testing]"' \;

# Install dash-renderer dependencies
echo "Installing dash-renderer dependencies..."
cd /workspace/dash/dash-renderer
npm ci
cd /workspace

# Setup virtual display
echo "Setting up virtual display..."
Xvfb :99 -ac -screen 0 1280x1024x24 > /dev/null 2>&1 &
XVFB_PID=$!
export DISPLAY=:99
sleep 2

# Run linting
echo ""
echo "Running linting..."
npm run lint

# Run unit tests
echo ""
echo "Running unit tests..."
npm run citest.unit

# Cleanup
kill $XVFB_PID 2>/dev/null || true

echo ""
echo "=========================================="
echo "All tests completed successfully!"
echo "=========================================="