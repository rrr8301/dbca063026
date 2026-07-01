#!/bin/bash

# Ensure that the environment variables GITHUB_PAT and GITHUB_USERNAME are set
if [[ -z "$GITHUB_PAT" || -z "$GITHUB_USERNAME" ]]; then
  echo "Error: GITHUB_PAT and GITHUB_USERNAME must be set."
  exit 1
fi

# Log in to GitHub Container Registry
echo "$GITHUB_PAT" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin