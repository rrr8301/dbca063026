FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git curl wget make gcc g++ tzdata && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Go using goenv
RUN git clone https://github.com/syndbg/goenv.git ~/.goenv && \
    echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.bashrc && \
    echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(goenv init -)"' >> ~/.bashrc

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/workspace/run.sh"]