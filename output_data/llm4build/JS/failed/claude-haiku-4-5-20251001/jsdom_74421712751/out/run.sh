#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies
npm ci --engine-strict

# Setup hosts file for web platform tests server
./test/web-platform-tests/tests/wpt make-hosts-file | sudo tee -a /etc/hosts

# Run tests
npm test