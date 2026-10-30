FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    git curl wget make gcc g++ tzdata ca-certificates && \
    rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Create non-root user
RUN useradd -m testuser

# Install Go using goenv
RUN git config --global http.sslVerify false && \
    git clone https://github.com/syndbg/goenv.git /home/testuser/.goenv && \
    mkdir -p /home/testuser/.goenv/versions && \
    chown -R testuser:testuser /home/testuser/.goenv && \
    echo 'export GOENV_ROOT="/home/testuser/.goenv"' >> /home/testuser/.bashrc && \
    echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> /home/testuser/.bashrc && \
    echo 'eval "$(goenv init -)"' >> /home/testuser/.bashrc

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Change ownership of workspace to testuser
RUN chown -R testuser:testuser /workspace

# Install gotesplit tool (provide the correct URL)
RUN curl -L -o /usr/local/bin/gotesplit https://correct-url.com/path/to/gotesplit && \
    chmod +x /usr/local/bin/gotesplit

# Switch to non-root user
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/workspace/run.sh"]