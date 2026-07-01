#!/bin/bash

set -e

# Update system package info
apt-get update

# Install system deps for proxygen and patchelf
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages install-system-deps --recursive patchelf

# Query paths for dependencies and save to file
python3 build/fbcode_builder/getdeps.py --allow-system-packages query-paths --recursive --src-dir=. proxygen > /tmp/paths.txt

# Parse the paths file and fetch dependencies if they exist
# Extract variable names and check if they have values
while IFS='=' read -r key value; do
    # Skip empty lines and comments
    [[ -z "$key" || "$key" =~ ^# ]] && continue
    
    # Check if this is a SOURCE variable
    if [[ "$key" == *"_SOURCE" ]]; then
        # Extract the package name (remove _SOURCE suffix)
        package="${key%_SOURCE}"
        
        # If value is not empty, fetch the package
        if [[ -n "$value" ]]; then
            echo "Fetching $package..."
            python3 build/fbcode_builder/getdeps.py --allow-system-packages fetch --no-tests "$package"
        fi
    fi
done < /tmp/paths.txt

# Build proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages build --src-dir=. proxygen --project-install-prefix proxygen:/usr/local

# Copy artifacts
python3 build/fbcode_builder/getdeps.py --allow-system-packages fixup-dyn-deps --strip --src-dir=. proxygen _artifacts/linux --project-install-prefix proxygen:/usr/local --final-install-prefix /usr/local

# Test proxygen
python3 build/fbcode_builder/getdeps.py --allow-system-packages test --src-dir=. proxygen --project-install-prefix proxygen:/usr/local