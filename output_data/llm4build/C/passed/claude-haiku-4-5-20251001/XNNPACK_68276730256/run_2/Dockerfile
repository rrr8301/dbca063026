FROM ghcr.io/google/xnnpack/standard:latest

# Create work directory
WORKDIR /workspace

# Copy repository (assumes context is the repo root)
COPY . /workspace/

# Set up ccache
ENV CMAKE_C_COMPILER_LAUNCHER=ccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache
ENV CCACHE_DIR=/home/xnnpack/.ccache

# Create ccache directory with proper permissions
RUN mkdir -p /home/xnnpack/.ccache && chmod 777 /home/xnnpack/.ccache

# Copy and set run script as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]