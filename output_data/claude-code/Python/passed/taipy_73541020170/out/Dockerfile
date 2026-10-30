FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3-pip \
    libmagic1 \
    libxss1 \
    libappindicator1 \
    libindicator7 \
    fonts-liberation \
    libnss3 \
    libappindicator3-1 \
    libxss1 \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 20 from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set python3.11 as default python and python3
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Replace Pipfile with max version for Python 3.11
RUN rm Pipfile && mv tools/packages/pipfiles/Pipfile3.11.max Pipfile

# Install pipenv with pip
RUN pip install "pipenv<2025.0.0"

# Install pipenv dependencies
RUN pipenv install --dev --python=3.11

# Hash frontend source code
RUN pipenv run python tools/frontend/hash_source.py

# Build frontend
RUN pipenv run python tools/frontend/bundle_build.py

# Install Playwright
RUN pipenv run playwright install chromium --with-deps

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
