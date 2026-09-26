FROM eclipse-temurin:25-jdk-noble

# Set timezone and locale
ENV TZ=UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    tzdata \
    unzip \
    gnupg \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git safe directory
RUN git config --global --add safe.directory '*'

# Copy and make run.sh executable (BEFORE switching to non-root user)
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create non-root user
RUN useradd -m testuser
RUN chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]