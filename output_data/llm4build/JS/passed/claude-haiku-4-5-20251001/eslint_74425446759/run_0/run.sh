#!/bin/bash
set -e

# Clone the repository
git clone https://github.com/eslint/eslint.git /workspace/repo
cd /workspace/repo

# Install npm packages
npm install

# Run mocha tests
node Makefile mocha

# Run fuzz tests
node Makefile fuzz

# Run EMFILE handling test
NODE_OPTIONS="" npm run test:emfile

echo "All tests completed successfully!"