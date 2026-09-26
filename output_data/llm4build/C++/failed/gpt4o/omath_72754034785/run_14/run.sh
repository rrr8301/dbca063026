#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Build the Docker image
docker build -t omath-image .

# Run the Docker container
docker run --rm -e GITHUB_TOKEN=your_github_token_here omath-image