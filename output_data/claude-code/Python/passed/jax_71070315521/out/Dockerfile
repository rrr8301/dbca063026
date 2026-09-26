FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_DEFAULT_INDEX="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"
ENV UV_MANAGED_PYTHON=true
ENV PIP_INDEX_URL="https://us-python.pkg.dev/ml-oss-artifacts-published/pypi-mirror/simple"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set up Python 3.11
RUN uv python install 3.11

WORKDIR /app

# Copy the JAX repository
COPY repo/ /app/

# Create a virtual environment and install JAX and test dependencies
RUN uv venv /app/venv --python 3.11 && \
    . /app/venv/bin/activate && \
    uv pip install '.[minimum-jaxlib]' -r 'build/test-requirements.txt'

# Copy the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
