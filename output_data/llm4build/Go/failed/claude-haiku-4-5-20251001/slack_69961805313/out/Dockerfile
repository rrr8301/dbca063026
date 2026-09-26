FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    golang-go \
    && rm -rf /var/lib/apt/lists/*

# Set Go environment variables
ENV PATH=$PATH:/usr/bin
ENV GOPATH=/go
RUN mkdir -p $GOPATH

# Create work directory
WORKDIR /workspace

# Copy entire project (including go.mod, go.sum, and source code)
COPY . /workspace/

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]