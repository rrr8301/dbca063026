FROM golang:1.25

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install jq 1.7
RUN curl -fsSL https://github.com/jqlang/jq/releases/download/jq-1.7/jq-linux-amd64 -o /usr/local/bin/jq && \
    chmod +x /usr/local/bin/jq

# Set Go environment
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]