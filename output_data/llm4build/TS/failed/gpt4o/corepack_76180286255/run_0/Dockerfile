FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 22.x and Yarn via Corepack
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    corepack enable

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Add non-root user
RUN useradd -m -u 1000 testuser && chown -R testuser /workspace

# Switch to non-root user
USER testuser

# Copy run.sh and set as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh
ENTRYPOINT ["/workspace/run.sh"]