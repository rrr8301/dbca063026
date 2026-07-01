FROM python:3.14-slim

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install uv and verify installation
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    /root/.cargo/bin/uv --version

# Set up work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Set environment variables - PATH must come after uv is installed
ENV UV_NO_SYNC=true
ENV UV_PYTHON=3.14
ENV UV_RESOLUTION=highest
ENV PATH="/root/.cargo/bin:$PATH"

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]