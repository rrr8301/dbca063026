#!/bin/bash

set -e

# Build 1: Main build with OpenCL, Vulkan, LLM, Audio, Vision support
echo "=== Building main configuration ==="
mkdir -p build && cd build
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
make -j4

# Test 1: Run main tests
echo "=== Running main tests ==="
./run_test.out || TEST1_FAILED=1

# Build 2: Non-SSE build
echo "=== Building non-SSE configuration ==="
cd /workspace
mkdir -p build_non_sse && cd build_non_sse
cmake -DMNN_BUILD_TEST=ON -DMNN_USE_SSE=OFF ..
make -j4

# Test 2: Run non-SSE tests
echo "=== Running non-SSE tests ==="
./run_test.out || TEST2_FAILED=1

# Build 3: AVX512 build
echo "=== Building AVX512 configuration ==="
cd /workspace
mkdir -p build_avx512 && cd build_avx512
cmake -DMNN_BUILD_TEST=ON -DMNN_AVX512=ON -DMNN_AVX512_VNNI=ON ..
make -j4

# Report results
echo "=== Build and Test Summary ==="
if [ -z "$TEST1_FAILED" ]; then
    echo "✓ Main tests passed"
else
    echo "✗ Main tests failed"
fi

if [ -z "$TEST2_FAILED" ]; then
    echo "✓ Non-SSE tests passed"
else
    echo "✗ Non-SSE tests failed"
fi

# Exit with failure if any test failed
if [ -n "$TEST1_FAILED" ] || [ -n "$TEST2_FAILED" ]; then
    exit 1
fi

exit 0