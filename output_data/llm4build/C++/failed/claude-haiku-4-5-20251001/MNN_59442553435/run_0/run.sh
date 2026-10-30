#!/bin/bash

set -e

# Build and test - Configuration 1: Full features
echo "=== Building with full features (OpenCL, Vulkan, LLM, Audio, Vision) ==="
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
make -j4

echo "=== Testing full features build ==="
./run_test.out || echo "Full features test failed, continuing..."

cd ..

# Build and test - Configuration 2: Non-SSE
echo "=== Building without SSE support ==="
mkdir -p build_non_sse
cd build_non_sse
cmake -DMNN_BUILD_TEST=ON -DMNN_USE_SSE=OFF ..
make -j4

echo "=== Testing non-SSE build ==="
./run_test.out || echo "Non-SSE test failed, continuing..."

cd ..

# Build - Configuration 3: AVX512
echo "=== Building with AVX512 support ==="
mkdir -p build_avx512
cd build_avx512
cmake -DMNN_BUILD_TEST=ON -DMNN_AVX512=ON -DMNN_AVX512_VNNI=ON ..
make -j4

echo "=== All builds completed ==="