FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    build-essential \
    ash \
    csh \
    fish \
    tcsh \
    zsh \
    sudo \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create work directory
WORKDIR /workspace

# Install Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh && \
    bash miniconda.sh -b -p /opt/miniconda && \
    rm miniconda.sh

# Add conda to PATH
ENV PATH="/opt/miniconda/bin:$PATH"

# Initialize conda for bash
RUN /opt/miniconda/bin/conda init bash

# Set conda environment variables
ENV CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true

# Copy repository
COPY . /workspace/

# Copy and execute run.sh
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]