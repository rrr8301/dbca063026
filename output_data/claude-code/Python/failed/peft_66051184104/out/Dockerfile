FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install setuptools
RUN python -m pip install --upgrade pip setuptools

# Set working directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Install project dependencies with test extras
RUN pip install -e .[test]

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set environment variables
ENV HF_HOME=.cache/huggingface
ENV TRANSFORMERS_IS_CI=1
ENV CI=1

ENTRYPOINT ["/run.sh"]
