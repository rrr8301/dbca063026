FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set CI environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    gcc \
    g++ \
    make \
    curl \
    wget \
    mysql-server \
    libasan6 \
    libubsan1 \
    libstdc++6 \
    python3.14 \
    python3.14-dev \
    python3.14-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.14 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.14 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.14 1

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Configure git to allow ownership mismatch
RUN git config --global --add safe.directory '*'

# Install pip dependencies
RUN python -m pip install --upgrade pip setuptools wheel coverage

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]