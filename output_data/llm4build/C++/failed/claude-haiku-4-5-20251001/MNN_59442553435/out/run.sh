#!/bin/bash

# Track overall test status
OVERALL_STATUS=0

# Build configuration 1: Full-featured build with OpenCL and Vulkan
echo "=== Building with full features (OpenCL, Vulkan, LLM, Audio) ==="
mkdir -p build
cd build
cmake .. \
    -DMNN_BUILD_TEST=ON \
    -DLLM_SUPPORT_VISION=true \
    -DMNN_BUILD_OPENCV=true \
    -DMNN_IMGCODECS=true \
    -DMNN_LOW_MEMORY=true \
    -DMNN_CPU_WEIGHT_DEQUANT_GEMM=true \
    -DMNN_BUILD_LLM=true \
    -DMNN_SUPPORT_TRANSFORMER_FUSE=true \
    -DLLM_SUPPORT_AUDIO=true \
    -DMNN_BUILD_AUDIO=true \
    -DMNN_OPENCL=ON \
    -DMNN_VULKAN=ON
if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed for full-featured build"
    OVERALL_STATUS=1
else
    make -j4
    if [ $? -ne 0 ]; then
        echo "ERROR: Build failed for full-featured build"
        OVERALL_STATUS=1
    fi
fi
cd ..

# Test configuration 1
if [ -f build/run_test.out ]; then
    echo "=== Testing full-featured build ==="
    cd build
    ./run_test.out
    TEST_STATUS=$?
    if [ $TEST_STATUS -ne 0 ]; then
        echo "WARNING: Full-featured build tests failed with status $TEST_STATUS"
        OVERALL_STATUS=1
    fi
    cd ..
else
    echo "ERROR: run_test.out not found in build directory"
    OVERALL_STATUS=1
fi

# Build configuration 2: Non-SSE build
echo "=== Building without SSE support ==="
mkdir -p build_non_sse
cd build_non_sse
cmake -DMNN_BUILD_TEST=ON -DMNN_USE_SSE=OFF ..
if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed for non-SSE build"
    OVERALL_STATUS=1
else
    make -j4
    if [ $? -ne 0 ]; then
        echo "ERROR: Build failed for non-SSE build"
        OVERALL_STATUS=1
    fi
fi
cd ..

# Test configuration 2
if [ -f build_non_sse/run_test.out ]; then
    echo "=== Testing non-SSE build ==="
    cd build_non_sse
    ./run_test.out
    TEST_STATUS=$?
    if [ $TEST_STATUS -ne 0 ]; then
        echo "WARNING: Non-SSE build tests failed with status $TEST_STATUS"
        OVERALL_STATUS=1
    fi
    cd ..
else
    echo "ERROR: run_test.out not found in build_non_sse directory"
    OVERALL_STATUS=1
fi

# Build configuration 3: AVX512 build
echo "=== Building with AVX512 support ==="
mkdir -p build_avx512
cd build_avx512
cmake -DMNN_BUILD_TEST=ON -DMNN_AVX512=ON -DMNN_AVX512_VNNI=ON ..
if [ $? -ne 0 ]; then
    echo "ERROR: CMake configuration failed for AVX512 build"
    OVERALL_STATUS=1
else
    make -j4
    if [ $? -ne 0 ]; then
        echo "ERROR: Build failed for AVX512 build"
        OVERALL_STATUS=1
    fi
fi
cd ..

# Test configuration 3
if [ -f build_avx512/run_test.out ]; then
    echo "=== Testing AVX512 build ==="
    cd build_avx512
    ./run_test.out
    TEST_STATUS=$?
    if [ $TEST_STATUS -ne 0 ]; then
        echo "WARNING: AVX512 build tests failed with status $TEST_STATUS"
        OVERALL_STATUS=1
    fi
    cd ..
else
    echo "ERROR: run_test.out not found in build_avx512 directory"
    OVERALL_STATUS=1
fi

echo "=== All builds and tests completed ==="
exit $OVERALL_STATUS