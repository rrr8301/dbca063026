FROM ubuntu:24.04

# Set timezone to Pacific Time and disable interactive prompts
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV FORCE_COLOR=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Configure git to trust the workspace directory
RUN git config --global --add safe.directory '*'

# Install uv (latest version)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH (uv installs to /root/.local/bin)
ENV PATH="/root/.local/bin:$PATH"

# Install tox@self using uv
RUN uv tool install --python-preference only-managed --python 3.12 tox@.

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]