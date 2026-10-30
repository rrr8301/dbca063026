FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    postgresql-client \
    postgresql \
    postgresql-contrib \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create work directory first to copy go.mod
WORKDIR /workspace
COPY go.mod go.sum* ./

# Extract Go version from go.mod
RUN GO_VERSION=$(grep "^go " go.mod | awk '{print $2}') && \
    curl -fsSL https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"

# Copy repository
COPY . .

# Make run.sh executable
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]