#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run the test command with GOTRACEBACK enabled
GOTRACEBACK=all make testnocgo