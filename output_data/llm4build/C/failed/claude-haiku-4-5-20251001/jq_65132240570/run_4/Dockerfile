FROM ubuntu:22.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    autoconf \
    automake \
    libtool \
    build-essential \
    make \
    gcc \
    g++ \
    pkg-config \
    libc6 \
    libc6-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository (assumes context is the jq repo root)
COPY . /workspace/

# Set environment variables
ENV LDFLAGS="-s"
ENV SUFFIX="linux-x86_64"

# Copy and make run.sh executable, convert line endings to LF
COPY run.sh /workspace/run.sh
RUN sed -i 's/\r$//' /workspace/run.sh && \
    chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]