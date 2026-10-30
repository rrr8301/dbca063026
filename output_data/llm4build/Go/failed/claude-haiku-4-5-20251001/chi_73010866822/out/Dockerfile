FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    make \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.24.x
RUN curl -fsSL https://go.dev/dl/go1.24.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

# Set up Go environment
ENV GOPATH=/go \
    PATH=/usr/local/go/bin:/go/bin:$PATH

# Create workspace directory
RUN mkdir -p $GOPATH/src/github.com

# Copy repository (assuming repo is at current context)
# The repository will be copied to the standard Go workspace path
WORKDIR $GOPATH/src/github.com
COPY . ./chi

# Set working directory to the project
WORKDIR $GOPATH/src/github.com/chi

# Copy and set entrypoint
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]