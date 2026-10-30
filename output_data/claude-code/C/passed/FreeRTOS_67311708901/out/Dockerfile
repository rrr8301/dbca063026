FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    git \
    lcov \
    cflow \
    ruby \
    doxygen \
    build-essential \
    unifdef \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone FreeRTOS repository with recursive submodules
RUN git clone --recursive --depth 5 https://github.com/FreeRTOS/FreeRTOS.git .

# Replace FreeRTOS/Source with the main branch from FreeRTOS-Kernel repository
RUN rm -rf FreeRTOS/Source && \
    git clone --depth 5 https://github.com/FreeRTOS/FreeRTOS-Kernel.git FreeRTOS/Source && \
    cd FreeRTOS/Source && \
    git checkout main

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
