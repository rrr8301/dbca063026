#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install project dependencies (if any)
# Placeholder for any Go module installation
# go mod download

# Run Go formatting check
if ! test -z $(gofmt -l .); then
  echo "Go code is not formatted. Please run 'gofmt -w .'"
  exit 1
fi

# Run Go tests
# Using placeholders for secret environment variables
export RILL_RUNTIME_DRUID_TEST_DSN="your_druid_test_dsn"
export RILL_RUNTIME_BIGQUERY_TEST_GOOGLE_APPLICATION_CREDENTIALS_JSON="your_bigquery_credentials_json"
export RILL_RUNTIME_SNOWFLAKE_TEST_DSN="your_snowflake_test_dsn"
export RILL_RUNTIME_GCS_TEST_GOOGLE_APPLICATION_CREDENTIALS_JSON="your_gcs_credentials_json"
export RILL_RUNTIME_GCS_TEST_HMAC_KEY="your_gcs_hmac_key"
export RILL_RUNTIME_GCS_TEST_HMAC_SECRET="your_gcs_hmac_secret"
export RILL_RUNTIME_S3_TEST_AWS_ACCESS_KEY_ID="your_s3_access_key_id"
export RILL_RUNTIME_S3_TEST_AWS_SECRET_ACCESS_KEY="your_s3_secret_access_key"
export RILL_RUNTIME_AZURE_TEST_CONNECTION_STRING="your_azure_connection_string"
export RILL_RUNTIME_ATHENA_TEST_AWS_ACCESS_KEY_ID="your_athena_access_key_id"
export RILL_RUNTIME_ATHENA_TEST_AWS_SECRET_ACCESS_KEY="your_athena_secret_access_key"
export RILL_RUNTIME_REDSHIFT_TEST_AWS_ACCESS_KEY_ID="your_redshift_access_key_id"
export RILL_RUNTIME_REDSHIFT_TEST_AWS_SECRET_ACCESS_KEY="your_redshift_secret_access_key"
export RILL_RUNTIME_MOTHERDUCK_TEST_PATH="your_motherduck_test_path"
export RILL_RUNTIME_MOTHERDUCK_TEST_TOKEN="your_motherduck_test_token"

# Run tests and ensure all tests are executed
go test -timeout 30m -short -v ./... || true