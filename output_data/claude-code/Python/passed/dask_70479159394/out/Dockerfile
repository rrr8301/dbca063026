FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    rm /tmp/miniforge.sh

ENV PATH="/opt/conda/bin:$PATH"

RUN conda config --system --prepend channels conda-forge && \
    conda config --system --set channel_priority strict

WORKDIR /app

COPY repo/ /app/

RUN conda env create -f continuous_integration/environment-3.11.yaml

RUN /bin/bash -c "source /opt/conda/etc/profile.d/conda.sh && conda activate test-environment && sed -i.bak 's/timeout_method = \"thread\"/timeout_method = \"signal\"/' pyproject.toml && python -m pip install --quiet --no-deps -e .[complete]"

ENV PARALLEL="true"
ENV COVERAGE="true"
ENV ARRAYEXPR="false"
ENV HDF5_USE_FILE_LOCKING="FALSE"

COPY run.sh /run.sh
RUN chmod +x /run.sh

SHELL ["/bin/bash", "-lc"]

ENTRYPOINT ["/run.sh"]
