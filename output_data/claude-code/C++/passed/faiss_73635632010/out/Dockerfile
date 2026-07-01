FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV OMP_NUM_THREADS=10
ENV MKL_THREADING_LAYER=GNU

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install mambaforge instead of miniconda for better conda-forge support
RUN wget -q https://github.com/conda-forge/miniforge/releases/download/24.3.0-0/Mambaforge-24.3.0-0-Linux-x86_64.sh && \
    bash Mambaforge-24.3.0-0-Linux-x86_64.sh -b -p /opt/conda && \
    rm Mambaforge-24.3.0-0-Linux-x86_64.sh

ENV PATH=/opt/conda/bin:$PATH

# Initialize conda
RUN conda init bash

# Install build dependencies from conda-forge
RUN conda install -y -q \
    python=3.12 \
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
    && conda clean -afy

# Copy the repository
COPY repo /app/
WORKDIR /app

# Create the run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
