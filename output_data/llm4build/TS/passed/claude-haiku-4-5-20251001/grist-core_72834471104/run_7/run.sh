#!/bin/bash
set -e

# Enable error handling: continue on test failures but track them
TESTS_FAILED=0

# Activate Python virtual environment if needed
export PYTHONUNBUFFERED=1

# Install Node.js dependencies
echo "Installing Node.js packages..."
yarn install || TESTS_FAILED=$?

if [ $TESTS_FAILED -ne 0 ]; then
    echo "Failed to install Node.js packages"
    exit 1
fi

# Install Python packages
echo "Installing Python packages..."
yarn run install:python || TESTS_FAILED=$?

if [ $TESTS_FAILED -ne 0 ]; then
    echo "Failed to install Python packages"
    exit 1
fi

# Install gvisor
echo "Installing gvisor..."
docker create --name temp-runsc gristlabs/gvisor-unprivileged:buster /bin/true || true
sudo docker cp temp-runsc:/runsc /usr/bin/runsc || true
docker rm temp-runsc || true

# Run eslint
echo "Running eslint..."
yarn run lint:ci || TESTS_FAILED=$?

# Build Node.js code
echo "Building Node.js code..."
yarn run build || TESTS_FAILED=$?

# Check nbrowser test-group coverage
echo "Checking nbrowser test-group coverage..."
node buildtools/check_test_groups.js || TESTS_FAILED=$?

# Install Google Chrome and chromedriver
echo "Installing Google Chrome and chromedriver..."
bash buildtools/install_chrome_for_tests.sh -y || TESTS_FAILED=$?

# Run smoke test
echo "Running smoke test..."
VERBOSE=1 DEBUG=1 MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:smoke || TESTS_FAILED=$?

# Run python tests
echo "Running Python tests..."
yarn run test:python || TESTS_FAILED=$?

# Run client tests
echo "Running client tests..."
yarn run test:client || TESTS_FAILED=$?

# Run common tests
echo "Running common tests..."
yarn run test:common || TESTS_FAILED=$?

# Run stubs tests
echo "Running stubs tests..."
MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:stubs || TESTS_FAILED=$?

# Run pyodide tests
echo "Running pyodide tests..."
cd sandbox/pyodide
make setup || TESTS_FAILED=$?
cd ../..
MOCHA_WEBDRIVER_HEADLESS=1 GRIST_SANDBOX_FLAVOR=pyodide yarn run test:server -g 'ActiveDoc.useQuerySet|Sandbox' || TESTS_FAILED=$?
MOCHA_WEBDRIVER_HEADLESS=1 GRIST_SANDBOX_FLAVOR=pyodide yarn run test:nbrowser -g 'Importer.*should.show.correct.preview' || TESTS_FAILED=$?

# Run eslint unit tests for custom rules
echo "Running eslint unit tests..."
yarn run test:eslint || TESTS_FAILED=$?

# Exit with appropriate code
if [ $TESTS_FAILED -ne 0 ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests completed successfully!"
exit 0