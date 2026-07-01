#!/bin/bash
set -e

# Start redis-server
echo "Starting redis-server..."
service redis-server start
sleep 2

# Function to run ctest with retry logic
run_tests_with_retry() {
    local max_attempts=3
    local timeout_minutes=90
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "=========================================="
        echo "Test attempt $attempt of $max_attempts"
        echo "=========================================="
        
        cd /workspace/cmake-build
        
        # Run ctest with timeout and output on failure
        # Exclude DataMySQL, DataODBC, PostgreSQL, MongoDB tests
        if timeout $((timeout_minutes * 60)) ctest --output-on-failure -E "(DataMySQL)|(DataODBC)|(PostgreSQL)|(MongoDB)"; then
            echo "Tests passed on attempt $attempt"
            return 0
        else
            local exit_code=$?
            echo "Tests failed on attempt $attempt with exit code $exit_code"
            
            if [ $attempt -lt $max_attempts ]; then
                echo "Retrying..."
                attempt=$((attempt + 1))
            else
                echo "All retry attempts exhausted"
                return $exit_code
            fi
        fi
    done
}

# Configure CMake project
echo "Configuring CMake project..."
cd /workspace
cmake -S. -Bcmake-build -GNinja -DENABLE_PDF=OFF -DENABLE_TESTS=ON

# Build project
echo "Building project..."
cmake --build cmake-build --target all --parallel 4

# Run tests with retry logic
echo "Running tests..."
run_tests_with_retry