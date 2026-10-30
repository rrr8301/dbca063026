#!/bin/bash

# Make sure the script is executable
chmod +x run.sh

# Check if Cargo.lock exists and copy it if it does
if [ -f Cargo.lock ]; then
    cp Cargo.lock Dockerfile_dir/
fi

# Build the Docker image
docker build -t my_rust_app_image .

# Run the Docker container
docker run --rm my_rust_app_image