FROM ubuntu:20.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    gettext \
    perl \
    cmake \
    libcurl4-openssl-dev \
    expat \
    libexpat1-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository (assumes context is the git repo root)
COPY . /workspace/

# Fix permissions on shell scripts
RUN find /workspace -type f -name "*.sh" -exec chmod +x {} \;

# Set environment variables from matrix
ENV CC=gcc
ENV CFLAGS="-Werror -Wall -Wextra"

# Copy and set entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]