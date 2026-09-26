FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata ca-certificates && \
    apt-get install -y --no-install-recommends git curl wget && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Go
RUN wget https://golang.org/dl/go1.17.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz && \
    rm go1.17.6.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace
RUN git config --global --add safe.directory '*'

# Set the correct Go version in go.mod
RUN sed -i 's/^go .*/go 1.17/' /workspace/go.mod

# Install Go dependencies
RUN go mod download

# Install gotestsum with a specific compatible version
RUN GOPATH=/workspace/go go install gotest.tools/gotestsum@v1.8.0

# Ensure Go binaries are available for non-root user
ENV GOPATH="/workspace/go"
ENV PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/workspace/run.sh"]