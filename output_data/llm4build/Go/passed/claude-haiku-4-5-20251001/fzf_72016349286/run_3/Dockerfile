FROM ubuntu:24.04

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    make \
    gcc \
    g++ \
    zsh \
    fish \
    tmux \
    shfmt \
    ca-certificates \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23.1 (first stable release in 1.23 series)
RUN curl -fsSL https://go.dev/dl/go1.23.1.linux-amd64.tar.gz -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Ruby 3.4.6
RUN apt-get update && apt-get install -y --no-install-recommends \
    ruby-full \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Install bundler
RUN gem install bundler

# Create non-root user for running tests
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set environment
ENV LANG=C.UTF-8
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Create working directory
WORKDIR /workspace
RUN chown -R testuser:testuser /workspace

# Copy repository contents
COPY --chown=testuser:testuser . /workspace/

# Copy run script
COPY --chown=testuser:testuser run.sh /run.sh
RUN chmod +x /run.sh

# Switch to non-root user
USER testuser

ENTRYPOINT ["/run.sh"]