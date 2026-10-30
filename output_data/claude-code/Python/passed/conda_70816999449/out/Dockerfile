FROM condaforge/mambaforge:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create the test environment
WORKDIR /app
COPY repo /app

# Create a conda condarc file
RUN echo -e "channels:\n  - defaults\nanaconda_anon_usage: false" > ~/.condarc

# Install conda dependencies using mamba
RUN mamba install -y \
    --file tests/requirements.txt \
    --file tests/requirements-Linux.txt \
    --file tests/requirements-ci.txt \
    --file tests/requirements-s3.txt \
    python=3.10 && \
    mamba clean -afy

# Install the conda package itself in development mode
RUN python -m pip install -e . --no-deps

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
