#!/bin/bash

# Build the Docker image
docker build --no-cache -t my-go-app .

# Run the Docker container
docker run --rm my-go-app