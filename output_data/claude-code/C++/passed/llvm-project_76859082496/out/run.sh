#!/usr/bin/env bash
set -e

cd /app

# Set up git config
git config --global --add safe.directory '*'

# Compute projects to build based on git diff
# For merge commits, we compare with the first parent
git log --oneline -1
git diff --name-only HEAD~1...HEAD > /tmp/changed_files.txt
echo "Changed files:"
cat /tmp/changed_files.txt

# Run compute_projects.py to determine what to build
source <(cat /tmp/changed_files.txt | python3 .ci/compute_projects.py)

if [[ "${projects_to_build}" == "" ]]; then
    echo "No projects to build"
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi

echo "Building projects: ${projects_to_build}"
echo "Running project checks targets: ${project_check_targets}"
echo "Building runtimes: ${runtimes_to_build}"
echo "Running runtimes checks targets: ${runtimes_check_targets}"
echo "Running runtimes checks requiring reconfiguring targets: ${runtimes_check_targets_needs_reconfig}"

# Set up compiler paths
export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

# Set sccache environment
export SCCACHE_IDLE_TIMEOUT=0

# Create artifacts directory
mkdir -p artifacts

# Start sccache
sccache --start-server 2>/dev/null || true

# Run the build script
./.ci/monolithic-linux.sh "${projects_to_build}" "${project_check_targets}" "${runtimes_to_build}" "${runtimes_check_targets}" "${runtimes_check_targets_needs_reconfig}" "${enable_cir}"

BUILD_RESULT=$?

if [ $BUILD_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi

exit $BUILD_RESULT
