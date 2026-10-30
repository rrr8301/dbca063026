FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    g++ \
    libblas-dev \
    libglu1-mesa-dev \
    liblapack-dev \
    xorg-dev \
    ccache \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CTEST_OUTPUT_ON_FAILURE=ON
ENV CTEST_PARALLEL_LEVEL=2
ENV IGL_NUM_THREADS=1

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]