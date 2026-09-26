FROM ubuntu:24.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    wget \
    libgdbm-dev \
    libdb-dev \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy the Perl source code from build context
COPY . /workspace/

# Copy run script and set permissions explicitly
COPY run.sh /workspace/run.sh
RUN chmod 755 /workspace/run.sh && \
    ls -la /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]