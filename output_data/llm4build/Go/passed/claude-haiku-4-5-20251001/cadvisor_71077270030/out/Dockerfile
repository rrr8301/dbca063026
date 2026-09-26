FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Install Go using the official golang image approach
# Download the latest stable Go version
RUN curl -fsSL https://go.dev/dl/?mode=json | jq -r '.[0].files[] | select(.os=="linux" and .arch=="amd64") | .filename' > /tmp/go_file.txt && \
    GO_FILE=$(cat /tmp/go_file.txt) && \
    curl -fsSL "https://go.dev/dl/${GO_FILE}" -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz /tmp/go_file.txt

# Set Go environment variables
ENV PATH="/usr/local/go/bin:${PATH}" \
    GOPATH="/root/go" \
    GOROOT="/usr/local/go"

# Verify Go installation
RUN go version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . .

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]