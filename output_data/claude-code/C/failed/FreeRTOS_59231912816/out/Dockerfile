FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/bin:$PATH"

# Install build dependencies and tools
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    python3 \
    python3-pip \
    lcov \
    cflow \
    ruby \
    doxygen \
    unifdef \
    gcc \
    make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the repository with submodules initialized
COPY repo/ /app/

# Initialize submodules to get CMock
RUN git submodule update --init --recursive -- FreeRTOS/Test/CMock/CMock

# Checkout FreeRTOS-Kernel main branch (like the workflow does)
RUN cd /app && git clone https://github.com/FreeRTOS/FreeRTOS-Kernel.git FreeRTOS/Source.tmp && \
    rm -rf FreeRTOS/Source && mv FreeRTOS/Source.tmp FreeRTOS/Source

# Copy and run the test script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
