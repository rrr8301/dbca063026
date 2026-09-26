FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

# Use Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

WORKDIR /app

COPY repo/ /app/

# Upgrade pip
RUN python -m pip install --upgrade pip

# Install project dependencies
RUN pip install -r requirements-dev.txt && \
    pip install pytest-cov && \
    pip install pytest-github-actions-annotate-failures

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
