FROM mambaorg/micromamba:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV OMP_NUM_THREADS=10
ENV MKL_THREADING_LAYER=GNU

USER root
WORKDIR /app
COPY repo/ /app/

RUN apt-get update -y && apt-get install -y \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

USER mambauser
ENV PATH="/opt/conda/bin:$PATH"

RUN micromamba install -y -c conda-forge \
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
    ccache

RUN micromamba clean --all --yes

USER root
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
