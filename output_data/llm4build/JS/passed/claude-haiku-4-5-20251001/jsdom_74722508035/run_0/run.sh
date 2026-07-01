#!/bin/bash
set -e

# Clone the repository with recursive submodules
git clone --recursive https://github.com/jsdom/jsdom.git /workspace
cd /workspace

# Setup hosts file for web platform tests server
./test/web-platform-tests/tests/wpt make-hosts-file >> /etc/hosts

# Install dependencies
npm ci --engine-strict

# Run tests
npm test