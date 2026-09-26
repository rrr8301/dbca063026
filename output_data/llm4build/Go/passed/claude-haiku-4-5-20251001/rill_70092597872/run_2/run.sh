#!/bin/bash

set -e

# Print Go version for verification
echo "Go version:"
go version

# Change to workspace directory
cd /workspace

# Download Go module dependencies
echo "Downloading Go dependencies..."
go mod download

# Run gofmt check
echo "Running gofmt check..."
if ! gofmt -l . | grep -q .; then
    echo "gofmt check passed"
else
    echo "gofmt check failed - files need formatting:"
    gofmt -l .
    exit 1
fi

# Run Go tests with 30m timeout, short flag, and verbose output
# Set environment variables for test connectors (use empty defaults if not provided)
echo "Running Go tests..."
export RILL_RUNTIME_DRUID_TEST_DSN="${RILL_RUNTIME_DRUID_TEST_DSN:-}"
export RILL_RUNTIME_BIGQUERY_TEST_GOOGLE_APPLICATION_CREDENTIALS_JSON="${RILL_RUNTIME_BIGQUERY_TEST_GOOGLE_APPLICATION_CREDENTIALS_JSON:-}"
export RILL_RUNTIME_SNOWFLAKE_TEST_DSN="${RILL_RUNTIME_SNOWFLAKE_TEST_DSN:-}"
export RILL_RUNTIME_GCS_TEST_GOOGLE_APPLICATION_CREDENTIALS_JSON="${RILL_RUNTIME_GCS_TEST_GOOGLE_APPLICATION_CREDENTIALS_JSON:-}"
export RILL_RUNTIME_GCS_TEST_HMAC_KEY="${RILL_RUNTIME_GCS_TEST_HMAC_KEY:-}"
export RILL_RUNTIME_GCS_TEST_HMAC_SECRET="${RILL_RUNTIME_GCS_TEST_HMAC_SECRET:-}"
export RILL_RUNTIME_S3_TEST_AWS_ACCESS_KEY_ID="${RILL_RUNTIME_S3_TEST_AWS_ACCESS_KEY_ID:-}"
export RILL_RUNTIME_S3_TEST_AWS_SECRET_ACCESS_KEY="${RILL_RUNTIME_S3_TEST_AWS_SECRET_ACCESS_KEY:-}"
export RILL_RUNTIME_AZURE_TEST_CONNECTION_STRING="${RILL_RUNTIME_AZURE_TEST_CONNECTION_STRING:-}"
export RILL_RUNTIME_ATHENA_TEST_AWS_ACCESS_KEY_ID="${RILL_RUNTIME_ATHENA_TEST_AWS_ACCESS_KEY_ID:-}"
export RILL_RUNTIME_ATHENA_TEST_AWS_SECRET_ACCESS_KEY="${RILL_RUNTIME_ATHENA_TEST_AWS_SECRET_ACCESS_KEY:-}"
export RILL_RUNTIME_REDSHIFT_TEST_AWS_ACCESS_KEY_ID="${RILL_RUNTIME_REDSHIFT_TEST_AWS_ACCESS_KEY_ID:-}"
export RILL_RUNTIME_REDSHIFT_TEST_AWS_SECRET_ACCESS_KEY="${RILL_RUNTIME_REDSHIFT_TEST_AWS_SECRET_ACCESS_KEY:-}"
export RILL_RUNTIME_MOTHERDUCK_TEST_PATH="${RILL_RUNTIME_MOTHERDUCK_TEST_PATH:-}"
export RILL_RUNTIME_MOTHERDUCK_TEST_TOKEN="${RILL_RUNTIME_MOTHERDUCK_TEST_TOKEN:-}"

# Run tests with timeout, short flag, and verbose output
go test -timeout 30m -short -v ./...

echo "All tests completed successfully!"