FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV MAKEFLAGS=V=1

# Create and set working directory
WORKDIR /workspace

# Copy the repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]