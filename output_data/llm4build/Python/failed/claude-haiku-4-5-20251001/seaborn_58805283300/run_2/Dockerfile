FROM ubuntu:22.04

# Set timezone to Pacific Time noninteractively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    make \
    curl \
    wget \
    python3.8 \
    python3.8-dev \
    python3.8-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.8 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1

# Upgrade pip and wheel
RUN python -m pip install --upgrade pip wheel

# Create workspace
WORKDIR /workspace

# Copy the repository
COPY . /workspace/

# Install seaborn with dev dependencies
RUN pip install --no-cache-dir ".[dev]"

# Create seaborn-data directory
RUN mkdir -p /workspace/seaborn-data

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set environment variables
ENV NB_KERNEL=python
ENV MPLBACKEND=Agg
ENV SEABORN_DATA=/workspace/seaborn-data
ENV PYDEVD_DISABLE_FILE_VALIDATION=1

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]