#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Configure git
git config --global --add safe.directory '*'

# Determine projects to build
projects_to_build=$(git diff --name-only HEAD~1...HEAD | python3 .ci/compute_projects.py)

if [[ -z "${projects_to_build}" ]]; then
  echo "No projects to build"
  exit 0
fi

echo "Building projects: ${projects_to_build}"

# Set environment variables
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

# Start sccache server
mkdir -p artifacts
SCCACHE_LOG=info SCCACHE_ERROR_LOG=$(pwd)/artifacts/sccache.log /usr/local/bin/sccache --start-server

# Run the build and test script
.ci/monolithic-linux.sh "${projects_to_build}" "${project_check_targets}" "${runtimes_to_build}" "${runtimes_check_targets}" "${runtimes_check_targets_needs_reconfig}" "${enable_cir}"

# Ensure python3 is used
python3 /workspace/.ci/premerge_advisor_upload.py $(git rev-parse HEAD)