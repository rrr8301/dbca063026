FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COLUMNS=150
ENV UV_FROZEN=true
ENV FORCE_COLOR=1
ENV OS=ubuntu-latest
ENV DEPS=yes
ENV UV_PYTHON_PREFERENCE=only-managed
ENV COVERAGE_FILE=coverage/.coverage.Linux-py3.12
ENV CONTEXT=Linux-py3.12-without-deps
ENV PATH="/root/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    pkg-config \
    libssl-dev \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    && rm -rf /var/lib/apt/lists/*

# Set python3 to python3.12
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Set up working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install dependencies using uv
RUN uv sync --all-packages --group testing-extra --all-extras

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
