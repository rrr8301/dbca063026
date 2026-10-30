FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV FORCE_COLOR=1

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-venv \
    python3-dev \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Make uv available in PATH
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app
COPY repo/ /app/

# Create wheel cache directory
RUN mkdir -p .wheel_cache

# Install Python 3.13 using uv and then install tox
RUN uv python install 3.13
RUN uv tool install --python-preference only-managed --python 3.13 tox@.

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
