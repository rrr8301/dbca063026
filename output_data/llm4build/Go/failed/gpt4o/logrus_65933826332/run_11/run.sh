#!/bin/bash

# Define the repository URL
REPO_URL="https://github.com/your/repository.git"  # Replace with the actual repository URL

# Optional: Define authentication credentials if the repository is private
USERNAME="your-username"  # Replace with your username
TOKEN="your-token"        # Replace with your token

# Check if the repository URL is public or requires authentication
if git ls-remote "$REPO_URL" &> /dev/null; then
    git clone "$REPO_URL" /app/repo
elif git ls-remote "https://${USERNAME}:${TOKEN}@${REPO_URL}" &> /dev/null; then
    git clone "https://${USERNAME}:${TOKEN}@${REPO_URL}" /app/repo
else
    echo "Repository is not accessible. Please check the URL or provide authentication."
    exit 1
fi

cd /app/repo || exit 1

# Run tests
go test -race -v ./...