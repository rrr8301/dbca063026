#!/bin/bash

# Build the Docker image
docker build -t my-go-app .

# Run the Docker container
docker run --rm my-go-app