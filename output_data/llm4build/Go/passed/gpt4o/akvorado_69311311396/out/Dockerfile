FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    jq \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -sSL https://golang.org/dl/go1.17.6.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH=$PATH:/usr/local/go/bin

# Create work directory
WORKDIR /app

# Copy repository files
COPY . .

# Verify Go installation and set up Go environment
RUN go version

# Install Go tools
RUN go env -w GO111MODULE=on
# Set GOPATH and ensure goimports is installed in a directory included in PATH
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# Fix the go.mod file to ensure compatibility
RUN sed -i 's/1.25.0/1.17/' go.mod

# Ensure go.mod has a valid Go version
RUN if ! grep -q '^go 1\.[0-9]\+$' go.mod; then \
        echo 'go 1.17' >> go.mod; \
    fi

# Remove invalid directives from go.mod before installing goimports
RUN sed -i '/toolchain/d' go.mod
RUN sed -i '/unknown block type: tool/d' go.mod

# Tidy up go.mod to ensure all dependencies are correct
RUN /usr/local/go/bin/go mod tidy || true

# Install goimports
RUN /usr/local/go/bin/go install golang.org/x/tools/cmd/goimports@v0.1.5

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]