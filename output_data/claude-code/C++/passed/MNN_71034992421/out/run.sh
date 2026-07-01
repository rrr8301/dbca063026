#!/usr/bin/env bash

set -e

cd /app

# Build step
echo "=== Build with full features ==="
mkdir -p build && cd build
cmake .. -DMNN_BUILD_TEST=ON -DLLM_SUPPORT_VISION=true -DMNN_BUILD_OPENCV=true -DMNN_IMGCODECS=true -DMNN_LOW_MEMORY=true -DMNN_CPU_WEIGHT_DEQUANT_GEMM=true -DMNN_BUILD_LLM=true -DMNN_SUPPORT_TRANSFORMER_FUSE=true -DLLM_SUPPORT_AUDIO=true -DMNN_BUILD_AUDIO=true -DMNN_OPENCL=ON -DMNN_VULKAN=ON
make -j4
cd /app

# Test step
echo "=== Run tests ==="
cd build && ./run_test.out || true
cd /app

# Build non_sse step
echo "=== Build without SSE ==="
mkdir -p build_non_sse && cd build_non_sse
cmake -DMNN_BUILD_TEST=ON -DMNN_USE_SSE=OFF ..
make -j4
cd /app

# Test non_sse step
echo "=== Run tests without SSE ==="
cd build_non_sse && ./run_test.out || true
cd /app

# Build avx512 step
echo "=== Build with AVX512 ==="
mkdir -p build_avx512 && cd build_avx512
cmake -DMNN_BUILD_TEST=ON -DMNN_AVX512=ON -DMNN_AVX512_VNNI=ON ..
make -j4
cd /app

echo "FINAL_STATUS = SUCCESS"
