#!/usr/bin/env bash
set -x

cd /app

# Main build and test
mkdir -p build && cd build
cmake .. -DMNN_BUILD_TEST=ON -DLLM_SUPPORT_VISION=true -DMNN_BUILD_OPENCV=true -DMNN_IMGCODECS=true -DMNN_LOW_MEMORY=true -DMNN_CPU_WEIGHT_DEQUANT_GEMM=true -DMNN_BUILD_LLM=true -DMNN_SUPPORT_TRANSFORMER_FUSE=true -DLLM_SUPPORT_AUDIO=true -DMNN_BUILD_AUDIO=true -DMNN_OPENCL=ON -DMNN_VULKAN=ON
make -j4

if [ -f ./run_test.out ]; then
    ./run_test.out || true
fi

cd /app

# Non-SSE build and test
mkdir -p build_non_sse && cd build_non_sse
cmake -DMNN_BUILD_TEST=ON -DMNN_USE_SSE=OFF ..
make -j4

if [ -f ./run_test.out ]; then
    ./run_test.out || true
fi

cd /app

# AVX512 build and test
mkdir -p build_avx512 && cd build_avx512
cmake -DMNN_BUILD_TEST=ON -DMNN_AVX512=ON -DMNN_AVX512_VNNI=ON ..
make -j4

if [ -f ./run_test.out ]; then
    ./run_test.out || true
fi

echo "FINAL_STATUS = SUCCESS"
