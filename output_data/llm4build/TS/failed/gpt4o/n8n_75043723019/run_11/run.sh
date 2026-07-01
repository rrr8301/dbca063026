#!/bin/bash

# Build the project
echo "Building project"
# Assuming a build script is defined in package.json
pnpm run build

# Run unit tests
echo "Running unit tests"
# Assuming a test script is defined in package.json
pnpm run test

# Send test statistics
echo "Sending test statistics"
# Assuming a script to send test statistics is defined in package.json
pnpm run send-test-stats

# Post build steps
echo "Post build steps"
# Assuming a post build script is defined in package.json
pnpm run post-build

# Complete runner
echo "Completing runner"
# Assuming a complete runner script is defined in package.json
pnpm run complete-runner

# Complete job
echo "Completing job"
# Assuming a complete job script is defined in package.json
pnpm run complete-job