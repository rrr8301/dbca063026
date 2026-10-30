FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_OPTIONS=--max-old-space-size=4096

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3.11-dev \
    python3-pip \
    curl \
    git \
    build-essential \
    libmagic1 \
    && rm -rf /var/lib/apt/lists/*

# Remove old Node.js and install Node.js 22
RUN apt-get update && \
    apt-get remove -y nodejs npm libnode-dev || true && \
    apt-get clean && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1

WORKDIR /app

COPY repo/ /app/

# Install pipenv
RUN pip install "pipenv<2025.0.0"

# Install Python dependencies with pipenv
RUN pipenv install --dev --python=3.11

# Install Node dependencies and build frontend
RUN cd /app && \
    pipenv run python tools/frontend/hash_source.py && \
    pipenv run python tools/frontend/bundle_build.py

# Install Playwright
RUN pipenv run playwright install chromium --with-deps

# Install xmltodict for coverage reporting
RUN pip install xmltodict

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
