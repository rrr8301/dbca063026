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
    build-essential \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create work directory first to copy go.mod
WORKDIR /workspace
COPY .git .git
COPY .gitmodules .gitmodules
COPY go.mod go.sum* ./

# Configure git to use HTTPS instead of SSH for submodules
RUN git config --global url."https://github.com/".insteadOf "git@github.com:" && \
    git config --global --add safe.directory /workspace && \
    git submodule update --init --recursive

# Extract Go version from go.mod and install
RUN GO_VERSION=$(grep "^go " go.mod | awk '{print $2}') && \
    echo "Installing Go version: $GO_VERSION" && \
    curl -fsSL https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    /usr/local/go/bin/go version

ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/root/go"
ENV PATH="$GOPATH/bin:$PATH"
ENV GOTOOLCHAIN="local"

# Copy repository
COPY . .

# Make run.sh executable
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]