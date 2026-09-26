FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_LIBMAMBA_SOLVER_NO_CHANNELS_FROM_INSTALLED=true

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    bzip2 \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    bash \
    ash \
    csh \
    fish \
    tcsh \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

ENV PATH=/opt/conda/bin:$PATH
ENV CONDA_OVERRIDE_CHANNELS_TOS=yes

# Create the test environment directory
WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Create condarc file for defaults channel
RUN mkdir -p /root && \
    echo "channels:" > /root/.condarc && \
    echo "  - defaults" >> /root/.condarc && \
    echo "anaconda_anon_usage: false" >> /root/.condarc

# Accept conda TOS for defaults channel
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

# Install conda dependencies
RUN conda install -y \
    --channel defaults \
    --file tests/requirements.txt \
    --file tests/requirements-Linux.txt \
    --file tests/requirements-ci.txt \
    --file tests/requirements-s3.txt \
    python=3.11 && \
    conda clean -afy

# Initialize all shells for integration tests
RUN /opt/conda/bin/python -m conda init --all

# Copy and set up run.sh
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
