#!/bin/bash

# Build and test with default settings
mkdir build && cd build
cmake .. -DMNN_BUILD_TEST=ON -DLLM_SUPPORT_VISION=true -DMNN_BUILD_OPENCV=true -DMNN_IMGCODECS=true -DMNN_LOW_MEMORY=true -DMNN_CPU_WEIGHT_DEQUANT_GEMM=true -DMNN_BUILD_LLM=true -DMNN_SUPPORT_TRANSFORMER_FUSE=true -DLLM_SUPPORT_AUDIO=true -DMNN_BUILD_AUDIO=true -DMNN_OPENCL=ON -DMNN_VULKAN=ON
make -j4
./run_test.out || true
cd ..

# Build and test without SSE
mkdir build_non_sse && cd build_non_sse
cmake -DMNN_BUILD_TEST=ON -DMNN_USE_SSE=OFF ..
make -j4
./run_test.out || true
cd ..

# Build with AVX512
mkdir build_avx512 && cd build_avx512
cmake -DMNN_BUILD_TEST=ON -DMNN_AVX512=ON -DMNN_AVX512_VNNI=ON ..
make -j4
cd ..