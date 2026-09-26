FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install --yes tzdata

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8

# Install necessary packages
RUN apt-get update && \
    apt-get install --yes zsh fish tmux shfmt git curl wget && \
    rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -sSL https://go.dev/dl/go1.23.0.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install Ruby
RUN apt-get update && \
    apt-get install --yes software-properties-common && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update && \
    apt-get install --yes ruby3.4 ruby3.4-dev && \
    rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Install Ruby gems
RUN gem install bundler && bundle install

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Create a non-root user and switch to it
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]