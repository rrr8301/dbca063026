FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV PY_COLORS=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv (latest stable binary)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ensure uv is in PATH
ENV PATH="/root/.local/bin:$PATH"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory (avoid ownership errors)
RUN git config --global --add safe.directory '*'

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]