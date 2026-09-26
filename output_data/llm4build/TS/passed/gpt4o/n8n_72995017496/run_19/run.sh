#!/bin/bash

# Start the application or service
# Replace 'your-start-command' with the actual command to start your application
# Ensure that the command is correct and executable
# Example: node server.js or npm start
# Replace 'your-start-command' with the actual command to start your application
# Example: node server.js or npm start
if [ -z "$1" ]; then
  echo "No start command provided. Please provide a command to start your application."
  exit 1
fi

exec "$@"