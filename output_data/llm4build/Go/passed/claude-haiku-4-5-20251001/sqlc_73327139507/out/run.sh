#!/bin/bash

set -e

# Enable error handling but continue on test failures
trap 'echo "Script encountered an error"' ERR

# Set Go environment variables
export GOPATH="/root/go"
export GOBIN="/root/go/bin"
export PATH="${GOBIN}:/usr/local/go/bin:${PATH}"
export CGO_ENABLED="0"

# Set database connection strings
export POSTGRESQL_SERVER_URI="postgres://postgres:postgres@127.0.0.1:5432/postgres?sslmode=disable"
export MYSQL_SERVER_URI="root:mysecretpassword@tcp(127.0.0.1:3306)/mysql?multiStatements=true&parseTime=true"

# Set placeholder secret variables (if needed by tests)
export CI_SQLC_PROJECT_ID="${CI_SQLC_PROJECT_ID:-placeholder-project-id}"
export CI_SQLC_AUTH_TOKEN="${CI_SQLC_AUTH_TOKEN:-placeholder-auth-token}"
export SQLC_AUTH_TOKEN="${SQLC_AUTH_TOKEN:-placeholder-auth-token}"

echo "=== Go Version ==="
go version

echo ""
echo "=== Installing gotestsum ==="
go install gotest.tools/gotestsum@latest

echo ""
echo "=== Installing sqlc-gen-test ==="
go install github.com/sqlc-dev/sqlc-gen-test@v0.1.0

echo ""
echo "=== Installing test-json-process-plugin ==="
go install ./scripts/test-json-process-plugin/

echo ""
echo "=== Installing project dependencies ==="
go install ./...

echo ""
echo "=== Building internal/endtoend testdata ==="
cd /workspace/internal/endtoend/testdata
go build ./...
cd /workspace

echo ""
echo "=== Installing databases ==="
go run ./cmd/sqlc-test-setup install || echo "Warning: Database installation may have failed, continuing..."

echo ""
echo "=== Starting databases ==="
go run ./cmd/sqlc-test-setup start || echo "Warning: Database startup may have failed, continuing..."

echo ""
echo "=== Running tests ==="
# Run tests with gotestsum, allowing failures but capturing output
gotestsum --junitfile junit.xml -- --tags=examples -timeout 20m -failfast ./... || TEST_RESULT=$?

echo ""
echo "=== Test Summary ==="
if [ -f junit.xml ]; then
    echo "JUnit XML report generated: junit.xml"
    cat junit.xml
fi

# Exit with test result if tests failed
if [ ! -z "$TEST_RESULT" ]; then
    exit $TEST_RESULT
fi

exit 0