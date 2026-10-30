FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add PostgreSQL official repository for PostgreSQL 13
RUN curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && apt-get install -y --no-install-recommends \
    postgresql-13 \
    postgresql-client-13 \
    && rm -rf /var/lib/apt/lists/*

# Install Go (assuming 1.21+ for ubuntu-latest)
RUN curl -fsSL https://go.dev/dl/go1.21.0.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:$PATH"

# Install gotestsum for JSON test output
RUN go install github.com/gotestyourself/gotestsum@latest

# Install Terraform (latest stable)
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y --no-install-recommends terraform && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set up Go cache directories
RUN mkdir -p /tmp/go-cache /tmp/go-mod-cache /tmp/go-path /tmp/go-tmp /tmp/embedded-pg-cache
ENV GOCACHE=/tmp/go-cache
ENV GOMODCACHE=/tmp/go-mod-cache
ENV GOPATH=/tmp/go-path
ENV GOTMPDIR=/tmp/go-tmp
ENV EMBEDDED_PG_CACHE_DIR=/tmp/embedded-pg-cache

# Download Go module dependencies
RUN go mod download

# Set entrypoint to run tests
ENTRYPOINT ["go", "test", "-v", "-parallel", "8", "-count=1", "./..."]