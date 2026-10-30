FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and add deadsnakes PPA for Python 3.12
RUN apt-get update && apt-get install -y \
    software-properties-common \
    curl \
    git \
    build-essential \
    python3-dev \
    xvfb \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y python3.12 python3.12-venv python3.12-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY repo/ /app/

# Install Node.js dependencies
RUN npm ci

# Set up Python 3.12
RUN python3.12 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
RUN python3.12 -m pip install --upgrade pip wheel && \
    python3.12 -m pip install "setuptools<80.0.0" && \
    python3.12 -m pip install build && \
    python3.12 -m pip install -e ".[dev,ci]"

# Build Dash
RUN npm run build

# Build packages
RUN python3.12 -m build --sdist --wheel && \
    mkdir -p packages && \
    cp dist/*.whl packages/

# Install Dash packages for testing
RUN python3.12 -m pip install --upgrade pip wheel && \
    python3.12 -m pip install "setuptools<80.0.0" && \
    find packages -name "dash-*.whl" -print -exec sh -c 'python3.12 -m pip install "{}[dev,ci,testing]"' \;

# Install dash-renderer dependencies
WORKDIR /app/dash/dash-renderer
RUN npm ci

WORKDIR /app

# Copy and set up the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
