FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    clang \
    lsb-release \
    wget \
    software-properties-common \
    gnupg \
    ca-certificates \
    git \
    cmake \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O - https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > /miniconda.sh && \
    bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh

ENV PATH=/opt/conda/bin:$PATH

RUN conda config --set auto_update_conda false && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

WORKDIR /app

COPY repo/ /app/

RUN conda env create -f test/pytest/environment.yml

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
