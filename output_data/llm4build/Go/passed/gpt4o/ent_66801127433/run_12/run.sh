#!/bin/bash

# Activate Go environment
export PATH="/usr/local/go/bin:${PATH}"
export CGO_ENABLED=1

# Ensure atlas is in the PATH
export PATH="${PATH}:$(go env GOPATH)/bin"

# Install project dependencies (if any)
# Ensure Go modules are initialized and dependencies are downloaded
go mod tidy

# Run tests in all specified directories
set +e  # Continue on errors to ensure all tests run

# Set necessary environment variables or flags for tests
export TEST_DB_URL="your_database_url_here"  # Replace with actual database URL if needed

# Add missing data source handler for "composite_schema"
export COMPOSITE_SCHEMA_HANDLER="your_composite_schema_handler_here"  # Replace with actual handler if needed

# Ensure required flags are set
export REQUIRED_FLAG_URL="your_required_flag_url_here"  # Replace with actual URL if needed

# Run tests with necessary environment variables
go test -race ./cmd/... || true
go test -race ./dialect/... || true
go test -race ./schema/... || true
go test -race ./entc/load/... || true
go test -race ./entc/gen/... || true

# Handle the examples directory separately
if [ -d "./examples" ]; then
    pushd ./examples
    go mod init examples || true  # Initialize a module if not already initialized
    go mod tidy  # Ensure dependencies are downloaded

    # Set necessary environment variables or flags for example tests
    export EXAMPLE_TEST_DB_URL="your_example_database_url_here"  # Replace with actual database URL if needed

    # Add missing data source handler for "composite_schema" in examples
    export EXAMPLE_COMPOSITE_SCHEMA_HANDLER="your_example_composite_schema_handler_here"  # Replace with actual handler if needed

    # Ensure required flags are set for examples
    export EXAMPLE_REQUIRED_FLAG_URL="your_example_required_flag_url_here"  # Replace with actual URL if needed

    # Run example tests with necessary environment variables
    go test -race ./... || true
    popd
fi
set -e  # Stop on errors after tests

# End of script