FROM golang:1.24

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Allow Go to automatically download newer toolchains if needed
ENV GOTOOLCHAIN=auto

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Go is already installed in the golang:1.24 base image
# Verify Go installation
RUN go version

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install gotestfmt
RUN go install github.com/gotesttools/gotestfmt/v2/cmd/gotestfmt@v2.4.1

# Default command to run tests
CMD ["sh", "-c", "MallocNanoZone=0 go test -race -json -v ./... 2>&1 | tee /tmp/gotest.log | gotestfmt"]