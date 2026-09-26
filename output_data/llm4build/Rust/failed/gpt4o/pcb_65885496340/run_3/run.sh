#!/bin/bash

# Ensure the script is executable
chmod +x run.sh

# Run the tests
cargo nextest run --workspace --profile ci --locked