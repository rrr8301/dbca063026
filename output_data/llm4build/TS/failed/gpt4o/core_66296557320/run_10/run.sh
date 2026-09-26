#!/bin/bash

# Ensure the script is executable
chmod +x run.sh

# Build the Docker image
docker build -t my-node-app .

# Run the Docker container
docker run --rm my-node-app