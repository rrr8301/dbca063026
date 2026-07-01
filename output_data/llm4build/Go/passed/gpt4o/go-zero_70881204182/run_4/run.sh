#!/bin/bash

# Build the Docker image
docker build -t my-go-app .

# Run the Docker container
docker run -p 8080:8080 my-go-app