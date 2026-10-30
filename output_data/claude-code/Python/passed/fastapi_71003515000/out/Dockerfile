FROM python:3.13-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive
ENV UV_NO_SYNC=true
ENV INLINE_SNAPSHOT_DEFAULT_FLAGS=review

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Set Python version
ENV UV_PYTHON=3.13

# Install dependencies using uv
RUN uv sync --no-dev --group tests --extra all

# Create coverage directory
RUN mkdir -p coverage

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
