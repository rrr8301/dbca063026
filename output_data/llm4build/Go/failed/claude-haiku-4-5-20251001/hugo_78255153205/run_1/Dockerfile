FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone before installing tzdata
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install base dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    tzdata \
    git \
    curl \
    wget \
    build-essential \
    pandoc \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.25.x
RUN curl -fsSL https://go.dev/dl/go1.25.0.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/root/go"
ENV GOBIN="/root/go/bin"
ENV PATH="${GOBIN}:${PATH}"

# Install Node 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Ruby 3.4.5
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    ruby-full \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Ruby gems
RUN gem install asciidoctor -v "2.0.26" && \
    gem install asciidoctor-diagram -v "3.1.0"

# Install Python packages
RUN pip3 install --no-cache-dir --break-system-packages docutils

# Install Go tools
RUN go install github.com/blampe/goat/cmd/goat@177de93b192b8ffae608e5d9ec421cc99bf68402 && \
    go install github.com/magefile/mage@v1.15.0 && \
    go install github.com/gohugoio/gotmplfmt@latest && \
    go install honnef.co/go/tools/cmd/staticcheck@latest

# Install Dart Sass
ENV SASS_VERSION=1.80.3
ENV DART_SASS_SHA_LINUX=7c933edbad0a7d389192c5b79393485c088bd2c4398e32f5754c32af006a9ffd
RUN curl -LJO "https://github.com/sass/dart-sass/releases/download/${SASS_VERSION}/dart-sass-${SASS_VERSION}-linux-x64.tar.gz" && \
    echo "${DART_SASS_SHA_LINUX}  dart-sass-${SASS_VERSION}-linux-x64.tar.gz" | sha256sum -c && \
    tar -xvf "dart-sass-${SASS_VERSION}-linux-x64.tar.gz" && \
    rm "dart-sass-${SASS_VERSION}-linux-x64.tar.gz"
ENV PATH="/dart-sass:${PATH}"

# Set environment variables for the build
ENV GOPROXY=https://proxy.golang.org
ENV GO111MODULE=on

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Create non-root user
RUN useradd -m testuser && \
    chown -R testuser:testuser /workspace

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]