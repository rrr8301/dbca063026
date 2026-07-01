#!/bin/bash

echo "Running the application..."
# Add your application start commands here
# For example, if you have a binary to run, you might do:
# ./your_application_binary

# Check if the necessary scripts are present and executable
if [[ ! -x /app/scripts/build-dependencies-qt.sh ]]; then
    echo "Error: build-dependencies-qt.sh is not executable or not found."
    exit 1
fi

if [[ ! -x /app/scripts/appimage-qt.sh ]]; then
    echo "Error: appimage-qt.sh is not executable or not found."
    exit 1
fi

# Execute the scripts if needed
/app/scripts/build-dependencies-qt.sh
/app/scripts/appimage-qt.sh

# Add any additional commands needed to start your application