#!/bin/bash
set -e

# Enable error handling with retry logic
retry_command() {
    local max_attempts=3
    local timeout_seconds=$((90 * 60))  # 90 minutes
    local retry_wait_seconds=10
    local attempt=1
    local exit_code=0

    while [ $attempt -le $max_attempts ]; do
        echo "Attempt $attempt of $max_attempts"
        
        # Run command with timeout
        if timeout $timeout_seconds bash -c "$1"; then
            exit_code=$?
            echo "Command succeeded on attempt $attempt"
            return $exit_code
        else
            exit_code=$?
            if [ $attempt -lt $max_attempts ]; then
                echo "Command failed with exit code $exit_code on attempt $attempt. Retrying in $retry_wait_seconds seconds..."
                sleep $retry_wait_seconds
            else
                echo "Command failed on final attempt $attempt with exit code $exit_code"
                return $exit_code
            fi
        fi
        
        attempt=$((attempt + 1))
    done
    
    return $exit_code
}

# Set up environment variables
export POCO_CMAKE_FULL_COMMON="-DPOCO_MINIMAL_BUILD=ON -DENABLE_TESTS=ON -DENABLE_XML=ON -DENABLE_JSON=ON -DENABLE_NET=ON -DENABLE_UTIL=ON -DENABLE_CRYPTO=ON -DENABLE_NETSSL=ON -DENABLE_JWT=ON -DENABLE_ENCODINGS=ON -DENABLE_PDF=ON -DENABLE_ZIP=ON -DENABLE_SEVENZIP=ON -DENABLE_REDIS=ON -DENABLE_MONGODB=ON -DENABLE_SSH=ON -DENABLE_DATA=ON -DENABLE_DATA_SQLITE=ON -DENABLE_PROMETHEUS=ON -DENABLE_ACTIVERECORD=ON -DENABLE_ACTIVERECORD_COMPILER=ON -DENABLE_CPPPARSER=ON -DENABLE_PAGECOMPILER=ON -DENABLE_POCODOC=ON -DENABLE_PAGECOMPILER_FILE2PAGE=ON"

export POCO_CMAKE_FULL_LINUX_EXTRA="-DENABLE_APACHECONNECTOR=ON -DENABLE_DNSSD=ON -DENABLE_DNSSD_DEFAULT=ON"

export POCO_CTEST_COMMON="--output-on-failure --no-tests=error --output-junit test-report.xml"

export POCO_CTEST_SANITIZER_EXTRA="--test-output-size-failed 0 --test-output-truncation tail"

export ASAN_OPTIONS=""

# System tuning for ASAN
echo "Configuring system for ASAN..."
sudo sysctl -w vm.mmap_rnd_bits=28

# Start services
echo "Starting Redis server..."
sudo service redis-server start
sleep 2

echo "Starting MongoDB..."
sudo service mongod start
sleep 3

# Verify services are running
echo "Verifying Redis is running..."
redis-cli ping || echo "Warning: Redis may not be responding"

echo "Verifying MongoDB is running..."
mongosh --eval "db.adminCommand('ping')" || echo "Warning: MongoDB may not be responding"

# Navigate to workspace
cd /workspace

# Configure CMake build
echo "Configuring CMake..."
cmake -S. -Bcmake-build -GNinja \
    -DPOCO_SANITIZEFLAGS="-fsanitize=address" \
    -DENABLE_TRACE=ON \
    $POCO_CMAKE_FULL_COMMON \
    $POCO_CMAKE_FULL_LINUX_EXTRA

# Build
echo "Building with Ninja..."
cmake --build cmake-build --target all --parallel $(nproc)

# Run tests with retry logic
echo "Running ctest with retry logic..."
retry_command "cd /workspace/cmake-build && ctest $POCO_CTEST_COMMON $POCO_CTEST_SANITIZER_EXTRA --parallel \$(nproc)"

echo "Test run completed successfully!"