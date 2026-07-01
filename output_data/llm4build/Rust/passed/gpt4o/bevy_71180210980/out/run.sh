#!/bin/bash

# Make sure the script is executable
chmod +x run.sh

# Build the Docker image
docker build -t my_rust_app_image .

# Run the Docker container
docker run --rm my_rust_app_image