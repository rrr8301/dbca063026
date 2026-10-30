#!/bin/bash

set -e

# Function to run commands and continue on error for test suite
run_command() {
    local name=$1
    shift
    echo "=========================================="
    echo "Running: $name"
    echo "=========================================="
    "$@" || {
        echo "⚠️  $name failed with exit code $?"
        return 1
    }
}

# Track overall success
OVERALL_SUCCESS=true

# Install dependencies
echo "Installing dependencies with bun..."
bun install --frozen-lockfile

# Run format check
if ! run_command "Format Check" bun run format; then
    OVERALL_SUCCESS=false
fi

# Run linter
if ! run_command "Linter" bun run lint; then
    OVERALL_SUCCESS=false
fi

# Run editorconfig checker
if ! run_command "EditorConfig Checker" bun run editorconfig-checker -format github-actions; then
    OVERALL_SUCCESS=false
fi

# Build project
if ! run_command "Build" bun run build; then
    OVERALL_SUCCESS=false
fi

# Run tests
if ! run_command "Tests" bun run test; then
    OVERALL_SUCCESS=false
fi

# Print summary
echo "=========================================="
echo "Test Suite Summary"
echo "=========================================="

if [ "$OVERALL_SUCCESS" = true ]; then
    echo "✅ All checks passed!"
    exit 0
else
    echo "❌ Some checks failed. See output above for details."
    exit 1
fi