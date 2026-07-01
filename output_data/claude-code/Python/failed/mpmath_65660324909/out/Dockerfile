FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    git \
    build-essential \
    libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy repo
COPY repo/ /app/

# Install dependencies from pyproject.toml using venv to avoid conflicts
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --upgrade pip setuptools setuptools-scm
RUN pip install --upgrade ".[develop,gmpy2,gmp,ci]"

# Copy and set up run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
