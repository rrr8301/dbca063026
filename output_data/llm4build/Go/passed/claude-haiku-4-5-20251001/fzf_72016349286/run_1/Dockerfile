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

# Set environment
ENV LANG=C.UTF-8
ENV GOPATH=/go
ENV PATH="${GOPATH}/bin:${PATH}"

# Create working directory
WORKDIR /workspace

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]