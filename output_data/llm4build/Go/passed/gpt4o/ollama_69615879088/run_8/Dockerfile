FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Install Go (updated to a more recent version)
RUN curl -sSL https://golang.org/dl/go1.20.5.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install golangci-lint
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v1.54.2

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Correct the Go version in go.mod
RUN sed -i 's/^go .*/go 1.20/' go.mod

# Install Go dependencies
RUN go mod tidy

# Install Node.js dependencies
WORKDIR /app/ui/app

# Ensure package.json exists before running npm ci
RUN if [ -f package.json ]; then npm ci; else echo "package.json not found"; fi

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]