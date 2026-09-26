# Dockerfile
FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    zsh fish tmux shfmt git curl wget make g++ \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://golang.org/dl/go1.23.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.23.linux-amd64.tar.gz && \
    rm go1.23.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Ruby
RUN apt-get update && apt-get install -y ruby-full && rm -rf /var/lib/apt/lists/*

# Set up work directory
WORKDIR /app

# Copy repository files
COPY . .

# Install Ruby gems
RUN gem install bundler && bundle install

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]