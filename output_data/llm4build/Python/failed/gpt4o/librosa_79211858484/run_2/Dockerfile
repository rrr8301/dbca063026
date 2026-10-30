FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y --no-install-recommends \
    libsamplerate0 \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install Miniforge
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O Miniforge3.sh && \
    bash Miniforge3.sh -b -p /opt/conda && \
    rm Miniforge3.sh
ENV PATH="/opt/conda/bin:$PATH"

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
COPY . /workspace
RUN chown -R testuser /workspace
RUN git config --global --add safe.directory '*'
USER testuser

# Initialize conda for bash
RUN /opt/conda/bin/conda init bash

# Install Python environment
RUN conda create -n test python=3.13 && \
    echo "conda activate test" >> ~/.bashrc

# Install project dependencies
RUN /bin/bash -c "source ~/.bashrc && conda activate test && conda env update -n test -f .github/environment-ci.yml"

# Install librosa with tests
RUN /bin/bash -c "source ~/.bashrc && conda activate test && python -m pip install --upgrade-strategy only-if-needed -e .[tests]"