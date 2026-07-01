FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    zsh \
    fish \
    tmux \
    shfmt \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.23
RUN curl -fsSL https://go.dev/dl/go1.23.0.linux-amd64.tar.gz -o go.tar.gz && \
    tar -xzf go.tar.gz -C /usr/local && \
    rm go.tar.gz && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go

# Install Ruby 3.4.6
RUN apt-get update && apt-get install -y --no-install-recommends \
    ruby \
    ruby-dev \
    rubygems \
    bundler \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Install Ruby gems
RUN bundle install

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
