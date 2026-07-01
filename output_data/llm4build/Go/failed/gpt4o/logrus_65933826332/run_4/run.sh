#!/bin/bash

# Define the repository URL
REPO_URL="https://github.com/your/repository.git"  # Replace with the actual repository URL

# Check if the repository URL is public or requires authentication
if git ls-remote "$REPO_URL" &> /dev/null; then
    git clone "$REPO_URL" /app/repo
else
    echo "Repository is not accessible. Please check the URL or provide authentication."
    exit 1
fi

cd /app/repo || exit 1

# Run tests
go test -race -v ./...