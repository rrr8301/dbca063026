#!/bin/bash

# Build the Docker image
docker build -t my-go-app .

# Run the Docker container with the GITHUB_TOKEN environment variable
docker run -e GITHUB_TOKEN=your_personal_access_token my-go-app