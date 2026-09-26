FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    postgresql-client \
    mysql-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.26.2
RUN curl -fsSL https://go.dev/dl/go1.26.2.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:$PATH" \
    GOPATH="/root/go" \
    GOBIN="/root/go/bin"
ENV PATH="$GOBIN:$PATH"

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and make run.sh executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set entrypoint
ENTRYPOINT ["/run.sh"]