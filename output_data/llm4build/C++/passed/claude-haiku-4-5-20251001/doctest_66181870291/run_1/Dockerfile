FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV CMAKE_GENERATOR=Ninja
ENV ASAN_OPTIONS=strict_string_checks=true:detect_odr_violation=2:detect_stack_use_after_return=true:check_initialization_order=true:strict_init_order=true
ENV TSAN_OPTIONS=force_seq_cst_atomics=1
ENV CTEST_OUTPUT_ON_FAILURE=ON
ENV CTEST_PARALLEL_LEVEL=2

# Install dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    valgrind \
    git \
    python3 \
    g++-9 \
    g++-9-multilib \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y libc6-dbg:i386 \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Copy and prepare run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]