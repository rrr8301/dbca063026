FROM gcc:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install CMake and Ninja
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
