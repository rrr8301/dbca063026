#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit status
TEST_FAILED=0

echo "=========================================="
echo "CI - Integration - Shade on Java 17"
echo "=========================================="

# Set timezone
export TZ=America/Los_Angeles

# Set JAVA_HOME for build (JDK 21)
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "Java version for build:"
java -version

# Navigate to workspace
cd /workspace

echo ""
echo "=========================================="
echo "Step 1: Tune Runner VM (OS-level optimizations)"
echo "=========================================="
# Apply OS-level tuning for Linux
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Configuring OS for optimal performance..."
    
    # Set swappiness to 1 to avoid swapping
    echo 1 | sudo tee /proc/sys/vm/swappiness > /dev/null || true
    
    # Configure Transparent HugePages
    echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null || true
    echo advise | sudo tee /sys/kernel/mm/transparent_hugepage/shmem_enabled > /dev/null || true
    echo defer+madvise | sudo tee /sys/kernel/mm/transparent_hugepage/defrag > /dev/null || true
    echo 1 | sudo tee /sys/kernel/mm/transparent_hugepage/khugepaged/defrag > /dev/null || true
    
    # Tune filesystem mount options
    sudo mount -o remount,nodiscard,commit=999999,barrier=0 / > /dev/null 2>&1 || true
    sudo mount -o remount,nodiscard,commit=999999,barrier=0 /mnt > /dev/null 2>&1 || true
    
    # Disable discard/trim
    for i in /sys/block/sd*/queue/discard_max_bytes; do
        echo 0 | sudo tee $i > /dev/null 2>&1 || true
    done
    
    echo "OS tuning completed."
fi

echo ""
echo "=========================================="
echo "Step 2: Display system information"
echo "=========================================="
echo "Available Memory:"
free -m || true
echo ""
echo "Available Disk Space:"
df -BM || true

echo ""
echo "=========================================="
echo "Step 3: Build project with Gradle"
echo "=========================================="
# Build the project using Gradle wrapper
if [ -f "./gradlew" ]; then
    echo "Building project with Gradle wrapper..."
    ./gradlew assemble -x test --no-daemon || {
        echo "WARNING: Gradle assemble failed, but continuing..."
    }
else
    echo "ERROR: Gradle wrapper not found"
    exit 1
fi

echo ""
echo "=========================================="
echo "Step 4: Run SHADE_BUILD setup commands"
echo "=========================================="
if [ -f "./pulsar-build/run_integration_group_gradle.sh" ]; then
    bash ./pulsar-build/run_integration_group_gradle.sh SHADE_BUILD || {
        echo "WARNING: SHADE_BUILD setup failed, but continuing..."
        TEST_FAILED=1
    }
else
    echo "WARNING: run_integration_group_gradle.sh not found, skipping SHADE_BUILD"
fi

echo ""
echo "=========================================="
echo "Step 5: Set up runtime JDK 17"
echo "=========================================="
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "Java version for runtime:"
java -version

echo ""
echo "=========================================="
echo "Step 6: Run integration test group 'SHADE_RUN'"
echo "=========================================="
if [ -f "./pulsar-build/run_integration_group_gradle.sh" ]; then
    bash ./pulsar-build/run_integration_group_gradle.sh SHADE_RUN || {
        echo "ERROR: SHADE_RUN integration tests failed"
        TEST_FAILED=1
    }
else
    echo "ERROR: run_integration_group_gradle.sh not found"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Step 7: Aggregate test reports"
echo "=========================================="
if [ -f "./pulsar-build/pulsar_ci_tool.sh" ]; then
    bash ./pulsar-build/pulsar_ci_tool.sh move_test_reports || {
        echo "WARNING: Failed to aggregate test reports"
    }
else
    echo "WARNING: pulsar_ci_tool.sh not found, skipping test report aggregation"
fi

echo ""
echo "=========================================="
echo "Step 8: Collect test reports and dumps"
echo "=========================================="
# Create test-reports directory if it doesn't exist
mkdir -p test-reports

# Copy test reports
if [ -d "tests/integration/build/reports/tests" ]; then
    cp -r tests/integration/build/reports/tests/* test-reports/ 2>/dev/null || true
fi

# Look for heap dumps, core dumps, or crash files
echo "Checking for heap dumps, core dumps, or crash files..."
find /tmp -name "*.hprof" -o -name "hs_err_*.log" -o -name "core.*" 2>/dev/null | head -20 || true

echo ""
echo "=========================================="
echo "Test Execution Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "All tests completed successfully!"
    exit 0
else
    echo "Some tests or setup steps failed. Check logs above for details."
    exit 1
fi