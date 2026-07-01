FROM ubuntu:22.04

# Set timezone to Pacific Time (non-interactive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3.11 \
    python3.11-dev \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip and setuptools
RUN python -m pip install --upgrade pip setuptools

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Install project dependencies from requirements.txt
RUN pip install -r requirements.txt --progress-bar off --upgrade

# Install tf_keras and remove conflicting packages
RUN pip install --no-deps tf_keras==2.20.0 && \
    pip uninstall -y keras keras-nightly || true

# Install project in editable mode
RUN pip install -e "." --progress-bar off --upgrade

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]