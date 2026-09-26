FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    wget \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install miniconda
RUN wget -q https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh

ENV PATH="/opt/conda/bin:$PATH"

# Initialize conda
RUN conda config --set solver libmamba && \
    conda config --set channel_priority strict && \
    conda config --add channels conda-forge

# Install conda packages
RUN conda install -y -q \
    python=3.11 \
    cmake=3.30.4 \
    make=4.2 \
    swig=4.0 \
    "numpy>=2.0,<3.0" \
    scipy=1.16 \
    pytest=7.4 \
    gflags=2.2 \
    setuptools \
    gxx_linux-64=14.2 \
    sysroot_linux-64=2.17 \
    mkl=2024.2.2 \
    mkl-devel=2024.2.2 \
    "pytorch<2.5" \
    -c pytorch \
    -c conda-forge

# Set environment variables
ENV OMP_NUM_THREADS=10
ENV MKL_THREADING_LAYER=GNU
ENV CONDA=/opt/conda

# Create working directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]