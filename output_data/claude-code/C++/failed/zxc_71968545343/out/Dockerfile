FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc-14 \
    g++-14 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up the compilers
ENV CC=gcc-14
ENV CXX=g++-14

WORKDIR /app
COPY repo/ /app/

# Run the build script
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/run.sh"]
