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

# Install Go 1.23
RUN apt-get update && apt-get install --yes golang-go && rm -rf /var/lib/apt/lists/* || \
    (curl -fsSL https://dl.google.com/go/go1.23.0.linux-amd64.tar.gz -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz)
ENV PATH="/usr/local/go/bin:$PATH"

# Install Ruby 3.4.6 with dependencies
RUN apt-get update && apt-get install --yes \
    ruby-dev \
    ruby-bundler \
    && rm -rf /var/lib/apt/lists/*

# Install Ruby 3.4.6 from source since apt repos may have older version
RUN apt-get update && apt-get install --yes \
    autoconf \
    bison \
    patch \
    && rm -rf /var/lib/apt/lists/* && \
    curl -fsSL https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.6.tar.gz -o /tmp/ruby.tar.gz && \
    tar -C /tmp -xzf /tmp/ruby.tar.gz && \
    cd /tmp/ruby-3.4.6 && \
    ./configure --prefix=/usr/local && \
    make && \
    make install && \
    rm -rf /tmp/ruby-3.4.6 /tmp/ruby.tar.gz

# Install Bundler
RUN gem install bundler

# Verify versions
RUN ruby --version && bundle --version && go version

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]