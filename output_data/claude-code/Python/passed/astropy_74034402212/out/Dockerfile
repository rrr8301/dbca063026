FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ARCH_ON_CI=normal
ENV IS_CRON=false
ENV PY_COLORS=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    language-pack-fr \
    tzdata \
    curl \
    wget \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install tox and related tools
RUN python3.12 -m pip install tox tox-uv uv --break-system-packages

WORKDIR /app
COPY repo/ /app/

# Copy and make run script executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
