#!/bin/bash

# Uninstall Docker
sudo systemctl stop docker
sudo systemctl stop docker.socket

# Run tests with pytest
export TESTS_SKIP_REQUIRES_DOCKER=true
pytest tests