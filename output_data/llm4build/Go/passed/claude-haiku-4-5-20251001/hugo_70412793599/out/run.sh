#!/bin/bash

set -e

# Environment variables
export GOPROXY=https://proxy.golang.org
export GO111MODULE=on
export SASS_VERSION=1.80.3
export DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd
export HUGO_BUILD_TAGS=extended,withdeploy

cd /workspace

# Clone the repository if not already present
if [ ! -d "/workspace/.git" ]; then
    echo "Cloning repository..."
    # Remove run.sh temporarily, clone, then restore it
    mv /workspace/run.sh /tmp/run.sh
    rm -rf /workspace/*
    git clone https://github.com/gohugoio/hugo.git /workspace
    mv /tmp/run.sh /workspace/run.sh
fi

cd /workspace

# Install GoAT
echo "Installing GoAT..."
go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402

# Install Mage
echo "Installing Mage..."
go install github.com/magefile/mage@v1.15.0

# Verify docutils installation
echo "Verifying docutils..."
rst2html --version

# Verify pandoc installation
echo "Verifying pandoc..."
pandoc -v

# Install dart-sass Linux version
echo "Installing Dart Sass version ${SASS_VERSION}..."
curl -LJO "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz"
tar -xzf "dart-sass-${SASS_VERSION}-linux-x64.tar.gz"
export PATH="/workspace/dart-sass:${PATH}"

# Verify dart-sass installation
echo "Verifying dart-sass..."
sass --version

# Run tests with Mage
echo "Running tests with Mage..."
mage -v test

echo "All tests completed!"