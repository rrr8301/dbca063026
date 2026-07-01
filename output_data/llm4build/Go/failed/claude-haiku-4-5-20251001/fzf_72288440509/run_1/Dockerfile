FROM ubuntu:24.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install --yes \
    git \
    curl \
    wget \
    build-essential \
    make \
    zsh \
    fish \
    tmux \
    shfmt \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23 using golang-go package or download from official source
RUN apt-get update && apt-get install --yes golang-go && rm -rf /var/lib/apt/lists/* || \
    (curl -fsSL https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz)
ENV PATH="/usr/local/go/bin:$PATH"

# Install Ruby 3.4.6
RUN apt-get update && apt-get install --yes \
    ruby-full \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Verify Ruby version
RUN ruby --version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]