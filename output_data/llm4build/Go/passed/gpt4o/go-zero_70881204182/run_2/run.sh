#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Build the Docker image
docker build -t my-go-app .

# Run the Docker container
docker run -p 8080:8080 my-go-app