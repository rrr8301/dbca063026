#!/bin/bash
set -e

# Enable error handling: continue on test failures but track them
TESTS_FAILED=0

# Activate Python virtual environment if needed
export PYTHONUNBUFFERED=1

# Set service URLs
export REDIS_URL=${REDIS_URL:-redis://localhost:6379}
export MINIO_URL=${MINIO_URL:-http://localhost:9000}
export MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY:-administrator}
export MINIO_SECRET_KEY=${MINIO_SECRET_KEY:-administrator}

echo "Installing Node.js packages..."
if ! yarn install; then
    echo "Failed to install Node.js packages"
    TESTS_FAILED=1
fi

if [ $TESTS_FAILED -ne 0 ]; then
    exit 1
fi

echo "Installing Python packages..."
if ! yarn run install:python; then
    echo "Failed to install Python packages"
    TESTS_FAILED=1
fi

if [ $TESTS_FAILED -ne 0 ]; then
    exit 1
fi

echo "Installing gvisor..."
docker create --name temp-runsc gristlabs/gvisor-unprivileged:buster /bin/true || true
sudo docker cp temp-runsc:/runsc /usr/bin/runsc || true
docker rm temp-runsc || true

echo "Running eslint..."
if ! yarn run lint:ci; then
    echo "Eslint check failed"
    TESTS_FAILED=1
fi

echo "Building Node.js code..."
if ! yarn run build; then
    echo "Failed to build Node.js code"
    TESTS_FAILED=1
fi

if [ $TESTS_FAILED -ne 0 ]; then
    exit 1
fi

echo "Checking nbrowser test-group coverage..."
if ! node buildtools/check_test_groups.js; then
    echo "Test group coverage check failed"
    TESTS_FAILED=1
fi

echo "Installing Google Chrome and chromedriver..."
if ! bash buildtools/install_chrome_for_tests.sh -y; then
    echo "Failed to install Chrome and chromedriver"
    TESTS_FAILED=1
fi

if [ $TESTS_FAILED -ne 0 ]; then
    exit 1
fi

echo "Running smoke test..."
if ! VERBOSE=1 DEBUG=1 MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:smoke; then
    echo "Smoke test failed"
    TESTS_FAILED=1
fi

echo "Running Python tests..."
if ! yarn run test:python; then
    echo "Python tests failed"
    TESTS_FAILED=1
fi

echo "Running client tests..."
if ! yarn run test:client; then
    echo "Client tests failed"
    TESTS_FAILED=1
fi

echo "Running common tests..."
if ! yarn run test:common; then
    echo "Common tests failed"
    TESTS_FAILED=1
fi

echo "Running stubs tests..."
if ! MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:stubs; then
    echo "Stubs tests failed"
    TESTS_FAILED=1
fi

echo "Running pyodide tests..."
if [ -d "sandbox/pyodide" ]; then
    cd sandbox/pyodide
    if ! make setup; then
        echo "Pyodide setup failed"
        TESTS_FAILED=1
    fi
    cd ../..
    
    if [ $TESTS_FAILED -eq 0 ]; then
        if ! MOCHA_WEBDRIVER_HEADLESS=1 GRIST_SANDBOX_FLAVOR=pyodide yarn run test:server -g 'ActiveDoc.useQuerySet|Sandbox'; then
            echo "Pyodide server tests failed"
            TESTS_FAILED=1
        fi
    fi
    
    if [ $TESTS_FAILED -eq 0 ]; then
        if ! MOCHA_WEBDRIVER_HEADLESS=1 GRIST_SANDBOX_FLAVOR=pyodide yarn run test:nbrowser -g 'Importer.*should.show.correct.preview'; then
            echo "Pyodide nbrowser tests failed"
            TESTS_FAILED=1
        fi
    fi
else
    echo "Warning: sandbox/pyodide directory not found, skipping pyodide tests"
fi

echo "Running eslint unit tests for custom rules..."
if ! yarn run test:eslint; then
    echo "Eslint unit tests failed"
    TESTS_FAILED=1
fi

# Exit with appropriate code
if [ $TESTS_FAILED -ne 0 ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests completed successfully!"
exit 0