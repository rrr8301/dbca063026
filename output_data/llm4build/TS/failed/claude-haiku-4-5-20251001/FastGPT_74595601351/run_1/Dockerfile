FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set timezone
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    git \
    curl \
    wget \
    build-essential \
    python3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install pnpm 10.33.2
RUN npm install -g pnpm@10.33.2

# Create non-root user
RUN useradd -m testuser

# Copy run script with executable permissions (before ownership change)
COPY --chmod=755 run.sh /workspace/run.sh

# Transfer ownership
RUN chown -R testuser:testuser /workspace

# Switch to non-root user
USER testuser

ENTRYPOINT ["/workspace/run.sh"]