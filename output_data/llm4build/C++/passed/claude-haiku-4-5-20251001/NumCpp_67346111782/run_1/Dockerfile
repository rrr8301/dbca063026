FROM ubuntu:22.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    cmake \
    git \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/miniconda && \
    rm /tmp/miniconda.sh

# Initialize conda
RUN /opt/miniconda/bin/conda init bash

# Accept Anaconda ToS for non-interactive environments
ENV CONDA_TOS_AGGREED=true

# Set working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Create conda environment from environment.yml
RUN /opt/miniconda/bin/conda env create -f /workspace/test/pytest/environment.yml

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]