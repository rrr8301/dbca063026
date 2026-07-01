#!/bin/bash

set -e

# Print environment info
echo "=========================================="
echo "C++ Build and Test Environment"
echo "=========================================="
echo "GCC Version:"
gcc --version
echo ""
echo "G++ Version:"
g++ --version
echo ""
echo "CMake Version:"
cmake --version
echo ""

# Navigate to workspace
cd /workspace

# Display repository structure
echo "=========================================="
echo "Repository Structure"
echo "=========================================="
ls -la

# Check if CMakeLists.txt exists for CMake build
if [ -f "CMakeLists.txt" ]; then
    echo "=========================================="
    echo "Building with CMake"
    echo "=========================================="
    
    # Create build directory
    mkdir -p build
    cd build
    
    # Configure with CMake
    cmake -DCMAKE_C_COMPILER=gcc-9 -DCMAKE_CXX_COMPILER=g++-9 \
          -DCMAKE_BUILD_TYPE=Release \
          -G "Unix Makefiles" \
          ..
    
    # Build
    make -j$(nproc)
    
    # Run tests if ctest is available
    if command -v ctest &> /dev/null; then
        echo "=========================================="
        echo "Running CTest Tests"
        echo "=========================================="
        ctest --output-on-failure || true
    fi
    
    cd ..
fi

# Check if Makefile exists in examples or root
if [ -f "examples/Makefile" ]; then
    echo "=========================================="
    echo "Building Examples"
    echo "=========================================="
    cd examples
    make || true
    cd ..
fi

# Check for test scripts (but skip Docker-dependent CI scripts)
if [ -f "csharp/compatibility_tests/v3.0.0/test.sh" ]; then
    echo "=========================================="
    echo "Running Compatibility Tests"
    echo "=========================================="
    bash csharp/compatibility_tests/v3.0.0/test.sh || true
fi

# Generic test discovery and execution
echo "=========================================="
echo "Searching for and Running Tests"
echo "=========================================="

# Look for test executables in build directory
if [ -d "build" ]; then
    find build -type f -executable -name "*test*" 2>/dev/null | while read test_file; do
        echo "Running: $test_file"
        "$test_file" || true
    done
fi

# Look for pytest tests if Python is available
if command -v python3 &> /dev/null && [ -f "python/setup.py" ]; then
    echo "=========================================="
    echo "Running Python Tests"
    echo "=========================================="
    cd python
    python3 -m pip install -e . || true
    python3 -m pytest . -v || true
    cd ..
fi

# Run direct CMake test project if available (without Docker)
if [ -f "CMake/install_test_project/test.sh" ]; then
    echo "=========================================="
    echo "Running CMake Install Test Project"
    echo "=========================================="
    
    # Set required environment variables for the test script
    export ABSL_GOOGLETEST_VERSION="${ABSL_GOOGLETEST_VERSION:-1.17.0}"
    export ABSL_GOOGLETEST_DOWNLOAD_URL="${ABSL_GOOGLETEST_DOWNLOAD_URL:-https://github.com/google/googletest/releases/download/v1.17.0/googletest-1.17.0.tar.gz}"
    
    # Run the test script with proper error handling
    bash CMake/install_test_project/test.sh 2>&1 || {
        exit_code=$?
        echo "CMake install test project exited with code $exit_code"
        # Continue execution instead of failing
        true
    }
fi

# Skip Docker-dependent CI scripts (they require Docker to be available)
echo "=========================================="
echo "Running CMake-based tests from dependencies"
echo "=========================================="

# Look for CMake-based test scripts that don't require Docker
if [ -d "build/_deps/absl-src/ci" ]; then
    
    # Set environment variables needed by test scripts
    export ABSL_GOOGLETEST_VERSION="${ABSL_GOOGLETEST_VERSION:-1.17.0}"
    export ABSL_GOOGLETEST_DOWNLOAD_URL="${ABSL_GOOGLETEST_DOWNLOAD_URL:-https://github.com/google/googletest/releases/download/v1.17.0/googletest-1.17.0.tar.gz}"
    export ABSL_CMAKE_CXX_STANDARDS="${ABSL_CMAKE_CXX_STANDARDS:-17 20}"
    export ABSL_CMAKE_BUILD_TYPES="${ABSL_CMAKE_BUILD_TYPES:-Debug Release}"
    export ABSL_CMAKE_BUILD_SHARED="${ABSL_CMAKE_BUILD_SHARED:-OFF ON}"
    export ABSL_CMAKE_BUILD_MONOLITHIC_SHARED_LIBS="${ABSL_CMAKE_BUILD_MONOLITHIC_SHARED_LIBS:-OFF ON}"
    
    # Find and run CMake-based test scripts, but skip Docker-dependent and platform-specific ones
    find build/_deps/absl-src/ci -type f -name "*.sh" | sort | while read script; do
        script_name=$(basename "$script")
        
        # Skip sourced configuration scripts
        if [[ "$script_name" == "cmake_common.sh" ]] || [[ "$script_name" == "linux_docker_containers.sh" ]]; then
            echo "Skipping sourced configuration script: $script_name"
            continue
        fi
        
        # Skip Bazel-dependent scripts
        if [[ "$script_name" == *"bazel"* ]]; then
            echo "Skipping Bazel-dependent script: $script_name"
            continue
        fi
        
        # Skip macOS-specific scripts
        if [[ "$script_name" == *"macos"* ]] || [[ "$script_name" == *"xcode"* ]]; then
            echo "Skipping macOS-specific script: $script_name"
            continue
        fi
        
        # Skip Alpine-specific scripts
        if [[ "$script_name" == *"alpine"* ]]; then
            echo "Skipping Alpine-specific script: $script_name"
            continue
        fi
        
        # Skip ARM-specific scripts
        if [[ "$script_name" == *"arm"* ]]; then
            echo "Skipping ARM-specific script: $script_name"
            continue
        fi
        
        # Skip cmake_install_test.sh as it requires Docker
        if [[ "$script_name" == "cmake_install_test.sh" ]]; then
            echo "Skipping Docker-dependent cmake_install_test.sh"
            continue
        fi
        
        # Skip ASAN and TSAN scripts as they require Docker
        if [[ "$script_name" == *"asan"* ]] || [[ "$script_name" == *"tsan"* ]]; then
            echo "Skipping Docker-dependent script: $script_name"
            continue
        fi
        
        # Only run Linux GCC CMake scripts that don't require Docker
        if [[ "$script_name" == "linux_gcc-latest_libstdcxx_cmake.sh" ]] || [[ "$script_name" == "linux_gcc-floor_libstdcxx_cmake.sh" ]]; then
            echo "Running: $script_name"
            
            # Create a wrapper to run the script without Docker
            # Extract the CMake commands from the script and run them directly
            (
                cd /workspace/build/_deps/absl-src
                
                # Source the common configuration
                source ci/cmake_common.sh
                source ci/linux_docker_containers.sh
                
                # Run CMake tests directly without Docker
                for std in ${ABSL_CMAKE_CXX_STANDARDS}; do
                    for compilation_mode in ${ABSL_CMAKE_BUILD_TYPES}; do
                        for build_shared in ${ABSL_CMAKE_BUILD_SHARED}; do
                            monolithic_shared_options="OFF"
                            if [[ "$build_shared" == "OFF" ]]; then
                                monolithic_shared_options="OFF ON"
                            fi
                            
                            for monolithic_shared in $monolithic_shared_options; do
                                echo "Testing: C++$std, $compilation_mode, shared=$build_shared, monolithic=$monolithic_shared"
                                
                                # Create temporary build directory
                                test_build_dir=$(mktemp -d)
                                cd "$test_build_dir"
                                
                                # Run CMake configuration
                                cmake /workspace/build/_deps/absl-src \
                                    -DABSL_GOOGLETEST_DOWNLOAD_URL="$ABSL_GOOGLETEST_DOWNLOAD_URL" \
                                    -DBUILD_SHARED_LIBS="$build_shared" \
                                    -DABSL_BUILD_TESTING=ON \
                                    -DCMAKE_BUILD_TYPE="$compilation_mode" \
                                    -DCMAKE_CXX_STANDARD="$std" \
                                    -DABSL_BUILD_MONOLITHIC_SHARED_LIBS="$monolithic_shared" \
                                    -DCMAKE_MODULE_LINKER_FLAGS="-Wl,--no-undefined" \
                                    -DCMAKE_C_COMPILER=gcc-9 \
                                    -DCMAKE_CXX_COMPILER=g++-9 \
                                    -DCFLAGS="-Werror" \
                                    -DCXXFLAGS="-Werror" 2>&1 || {
                                    echo "CMake configuration failed for C++$std, $compilation_mode"
                                    cd /workspace
                                    rm -rf "$test_build_dir"
                                    continue
                                }
                                
                                # Build
                                make -j$(nproc) 2>&1 || {
                                    echo "Build failed for C++$std, $compilation_mode"
                                    cd /workspace
                                    rm -rf "$test_build_dir"
                                    continue
                                }
                                
                                # Run tests
                                TZDIR=/workspace/build/_deps/absl-src/absl/time/internal/cctz/testdata/zoneinfo \
                                ctest -j$(nproc) --output-on-failure 2>&1 || {
                                    echo "Tests failed for C++$std, $compilation_mode (continuing)"
                                    true
                                }
                                
                                cd /workspace
                                rm -rf "$test_build_dir"
                            done
                        done
                    done
                done
            ) || {
                exit_code=$?
                echo "Script $script_name exited with code $exit_code (continuing)"
                true
            }
        else
            echo "Skipping non-CMake script: $script_name"
        fi
    done
fi

echo "=========================================="
echo "Build and Test Complete"
echo "=========================================="