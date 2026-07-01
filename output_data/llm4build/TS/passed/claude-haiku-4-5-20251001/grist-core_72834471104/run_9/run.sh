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

# Function to handle test failures
handle_test_failure() {
    local test_name=$1
    echo "❌ $test_name failed"
    TESTS_FAILED=1
}

# Function to handle test success
handle_test_success() {
    local test_name=$1
    echo "✅ $test_name passed"
}

echo "=========================================="
echo "Starting test suite..."
echo "=========================================="

echo ""
echo "Installing Node.js packages..."
if yarn install; then
    handle_test_success "Node.js packages installation"
else
    handle_test_failure "Node.js packages installation"
    exit 1
fi

echo ""
echo "Installing Python packages..."
if yarn run install:python; then
    handle_test_success "Python packages installation"
else
    handle_test_failure "Python packages installation"
    exit 1
fi

echo ""
echo "Installing gvisor..."
if docker create --name temp-runsc gristlabs/gvisor-unprivileged:buster /bin/true 2>/dev/null || true; then
    if sudo docker cp temp-runsc:/runsc /usr/bin/runsc 2>/dev/null || true; then
        handle_test_success "gvisor installation"
    fi
    docker rm temp-runsc 2>/dev/null || true
fi

echo ""
echo "Running eslint..."
if yarn run lint:ci; then
    handle_test_success "Eslint check"
else
    handle_test_failure "Eslint check"
fi

echo ""
echo "Building Node.js code..."
if yarn run build; then
    handle_test_success "Node.js build"
else
    handle_test_failure "Node.js build"
    exit 1
fi

echo ""
echo "Checking nbrowser test-group coverage..."
if node buildtools/check_test_groups.js; then
    handle_test_success "Test group coverage check"
else
    handle_test_failure "Test group coverage check"
fi

echo ""
echo "Installing Google Chrome and chromedriver..."
if bash buildtools/install_chrome_for_tests.sh -y; then
    handle_test_success "Chrome and chromedriver installation"
else
    handle_test_failure "Chrome and chromedriver installation"
    exit 1
fi

echo ""
echo "Running smoke test..."
if VERBOSE=1 DEBUG=1 MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:smoke; then
    handle_test_success "Smoke test"
else
    handle_test_failure "Smoke test"
fi

echo ""
echo "Running Python tests..."
if yarn run test:python; then
    handle_test_success "Python tests"
else
    handle_test_failure "Python tests"
fi

echo ""
echo "Running client tests..."
if yarn run test:client; then
    handle_test_success "Client tests"
else
    handle_test_failure "Client tests"
fi

echo ""
echo "Running common tests..."
if yarn run test:common; then
    handle_test_success "Common tests"
else
    handle_test_failure "Common tests"
fi

echo ""
echo "Running stubs tests..."
if MOCHA_WEBDRIVER_HEADLESS=1 yarn run test:stubs; then
    handle_test_success "Stubs tests"
else
    handle_test_failure "Stubs tests"
fi

echo ""
echo "Running pyodide tests..."
if [ -d "sandbox/pyodide" ]; then
    cd sandbox/pyodide
    if make setup; then
        handle_test_success "Pyodide setup"
        cd ../..
        
        if MOCHA_WEBDRIVER_HEADLESS=1 GRIST_SANDBOX_FLAVOR=pyodide yarn run test:server -g 'ActiveDoc.useQuerySet|Sandbox'; then
            handle_test_success "Pyodide server tests"
        else
            handle_test_failure "Pyodide server tests"
        fi
        
        if MOCHA_WEBDRIVER_HEADLESS=1 GRIST_SANDBOX_FLAVOR=pyodide yarn run test:nbrowser -g 'Importer.*should.show.correct.preview'; then
            handle_test_success "Pyodide nbrowser tests"
        else
            handle_test_failure "Pyodide nbrowser tests"
        fi
    else
        handle_test_failure "Pyodide setup"
        cd ../..
    fi
else
    echo "⚠️  Warning: sandbox/pyodide directory not found, skipping pyodide tests"
fi

echo ""
echo "Running eslint unit tests for custom rules..."
if yarn run test:eslint; then
    handle_test_success "Eslint unit tests"
else
    handle_test_failure "Eslint unit tests"
fi

echo ""
echo "=========================================="
# Exit with appropriate code
if [ $TESTS_FAILED -ne 0 ]; then
    echo "❌ Some tests failed!"
    echo "=========================================="
    exit 1
fi

echo "✅ All tests completed successfully!"
echo "=========================================="
exit 0