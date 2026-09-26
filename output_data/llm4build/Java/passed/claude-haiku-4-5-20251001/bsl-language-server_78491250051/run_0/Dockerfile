FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Set UTF-8 locale
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git safe directory (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Create non-root user and transfer ownership
RUN useradd -m testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]