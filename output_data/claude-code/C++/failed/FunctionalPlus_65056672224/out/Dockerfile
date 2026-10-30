FROM teeks99/clang-ubuntu:22

ENV DEBIAN_FRONTEND=noninteractive
ENV CC=clang-22
ENV CXX=clang++-22
ENV CXXFLAGS=-stdlib=libc++
ENV CMAKE_PREFIX_PATH=/root/.local:${CMAKE_PREFIX_PATH}

WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y git libunwind-22-dev cmake && \
    rm -rf /var/lib/apt/lists/*

# Copy repository
COPY repo/ /app/

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
