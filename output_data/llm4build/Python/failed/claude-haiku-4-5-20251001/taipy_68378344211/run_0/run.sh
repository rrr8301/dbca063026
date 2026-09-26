#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Install pipenv dependencies (min version as per workflow)
echo "Installing pipenv dependencies..."
pipenv install --dev --python=3.11

# Install Node.js dependencies for frontend
echo "Installing Node.js dependencies..."
npm install

# Build frontend bundle
echo "Building frontend bundle..."
pipenv run python tools/frontend/bundle_build.py

# Install Playwright with chromium and system dependencies
echo "Installing Playwright..."
pipenv run playwright install chromium --with-deps

# Install additional Python packages for coverage
echo "Installing coverage tools..."
python -m pip install xmltodict

# Run pytest with coverage
echo "Running pytest with coverage..."
pipenv run pytest --cov=taipy --cov-report=xml:/workspace/coverage.xml --cov-config=.coveragerc

# Fetch base branch (simulate PR base branch as 'develop')
echo "Fetching base branch..."
git fetch origin develop:refs/remotes/origin/develop || true

# Check total project coverage
echo "Checking total project coverage..."
python tools/coverage_check.py check-total --coverage-file /workspace/coverage.xml --threshold 80

# Check pull request coverage (use develop as base branch)
echo "Checking pull request coverage..."
python tools/coverage_check.py check-changed --coverage-file /workspace/coverage.xml --threshold 80 --base-branch develop

echo "Coverage tests completed successfully!"