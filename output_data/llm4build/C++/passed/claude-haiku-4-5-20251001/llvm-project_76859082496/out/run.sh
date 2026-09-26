#!/bin/bash

set -e

# Configure git to allow safe directory access
git config --global --add safe.directory '*'

# Set environment variables
export CC=/opt/llvm/bin/clang
export CXX=/opt/llvm/bin/clang++
export GITHUB_TOKEN="${GITHUB_TOKEN:-}"
export GITHUB_PR_NUMBER="${GITHUB_PR_NUMBER:-}"

# Compute projects to build based on git diff
# For local builds, we'll build all projects if no git history is available
if git rev-parse HEAD~1 >/dev/null 2>&1; then
    source <(git diff --name-only HEAD~1...HEAD | python3 .ci/compute_projects.py)
else
    # Fallback: build all projects if we can't compute diff
    echo "Warning: Cannot compute git diff (shallow clone or single commit). Building all projects."
    projects_to_build=""
    project_check_targets=""
    runtimes_to_build=""
    runtimes_check_targets=""
    runtimes_check_targets_needs_reconfig=""
    enable_cir=""
fi

if [[ "${projects_to_build}" == "" ]]; then
    echo "No projects to build"
    exit 0
fi

echo "Building projects: ${projects_to_build}"
echo "Running project checks targets: ${project_check_targets}"
echo "Building runtimes: ${runtimes_to_build}"
echo "Running runtimes checks targets: ${runtimes_check_targets}"
echo "Running runtimes checks requiring reconfiguring targets: ${runtimes_check_targets_needs_reconfig}"

# Create artifacts directory
mkdir -p artifacts

# Start sccache server (optional, for local caching)
if command -v sccache &> /dev/null; then
    export SCCACHE_LOG=info
    export SCCACHE_ERROR_LOG=$(pwd)/artifacts/sccache.log
    sccache --start-server || true
fi

# Run the main build and test script
./.ci/monolithic-linux.sh "${projects_to_build}" "${project_check_targets}" "${runtimes_to_build}" "${runtimes_check_targets}" "${runtimes_check_targets_needs_reconfig}" "${enable_cir}"

echo "Build and test completed successfully"