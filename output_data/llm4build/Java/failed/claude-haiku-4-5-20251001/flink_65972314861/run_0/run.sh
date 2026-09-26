#!/bin/bash

set -e

# Environment setup
export JAVA_HOME=$JAVA_HOME_17_X64
export PATH=$JAVA_HOME_17_X64/bin:$PATH

# Set environment variables for the build
export MOUNTED_WORKING_DIR=/root/flink
export CONTAINER_LOCAL_WORKING_DIR=/root/flink
export FLINK_ARTIFACT_DIR=/root/artifact-directory
export FLINK_ARTIFACT_FILENAME=flink_artifacts.tar.gz
export MAVEN_REPO_FOLDER=/root/.m2/repository
export MAVEN_ARGS="-Dmaven.repo.local=/root/.m2/repository"
export DOCKER_IMAGES_CACHE_FOLDER=/root/.docker-cache

# Set S3 credentials (use placeholders or pass via environment)
export IT_CASE_S3_BUCKET="${IT_CASE_S3_BUCKET:-}"
export IT_CASE_S3_ACCESS_KEY="${IT_CASE_S3_ACCESS_KEY:-}"
export IT_CASE_S3_SECRET_KEY="${IT_CASE_S3_SECRET_KEY:-}"

# Set Maven profile and JDK options
export PROFILE="-Dinclude_hadoop_aws -Djdk17 -Pjava17-target"

# Create necessary directories
mkdir -p "$FLINK_ARTIFACT_DIR"
mkdir -p "$MAVEN_REPO_FOLDER"
mkdir -p "$DOCKER_IMAGES_CACHE_FOLDER"

# Change to working directory
cd "$CONTAINER_LOCAL_WORKING_DIR"

echo "=========================================="
echo "Step 1: Compile Flink (test-compile phase)"
echo "=========================================="

# Source Maven utilities
source "./tools/ci/maven-utils.sh"

# Run Maven test-compile
$PROFILE run_mvn test-compile -Dflink.markBundledAsOptional=false -Dfast

echo "=========================================="
echo "Step 2: Create build artifacts"
echo "=========================================="

# Create build artifacts (simulate artifact creation)
./tools/azure-pipelines/create_build_artifact.sh

echo "=========================================="
echo "Step 3: Unpack build artifacts"
echo "=========================================="

# Unpack build artifacts
./tools/azure-pipelines/unpack_build_artifact.sh

echo "=========================================="
echo "Step 4: Set coredump pattern"
echo "=========================================="

# Set coredump pattern for debugging
sudo sysctl -w kernel.core_pattern=core.%p || true

echo "=========================================="
echo "Step 5: Load Docker images (if needed)"
echo "=========================================="

# Load Docker images from cache if available
if [ -f "./tools/azure-pipelines/cache_docker_images.sh" ]; then
    ./tools/azure-pipelines/cache_docker_images.sh load || true
fi

echo "=========================================="
echo "Step 6: Run tests for module: table"
echo "=========================================="

# Run tests for the table module
# Set additional profile for GitHub Actions
export PROFILE="$PROFILE -Pgithub-actions"

# Run the test controller
$PROFILE ./tools/azure-pipelines/uploading_watchdog.sh \
    ./tools/ci/test_controller.sh table || TEST_FAILED=1

echo "=========================================="
echo "Step 7: Post-build disk info"
echo "=========================================="

# Display disk usage
df -h

echo "=========================================="
echo "Step 8: Top 15 biggest directories"
echo "=========================================="

# Show top 15 biggest directories
du -ah --exclude="proc" -t100M . 2>/dev/null | sort -h -r | head -n 15 || true

echo "=========================================="
echo "Step 9: Save Docker images to cache"
echo "=========================================="

# Save Docker images to cache
if [ -f "./tools/azure-pipelines/cache_docker_images.sh" ]; then
    ./tools/azure-pipelines/cache_docker_images.sh save || true
fi

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed, but continuing for diagnostics."
    exit 1
fi

exit 0