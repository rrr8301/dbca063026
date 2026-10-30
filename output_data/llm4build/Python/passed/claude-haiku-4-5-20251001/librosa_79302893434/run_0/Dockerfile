FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && apt-get install -y tzdata locales && locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install OS dependencies
RUN apt-get update && apt-get install -y \
    libsamplerate0 \
    git \
    curl \
    wget

# Install Miniforge
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O miniforge.sh && \
    bash miniforge.sh -b -p /opt/conda && \
    rm miniforge.sh
ENV PATH="/opt/conda/bin:$PATH"

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Update Conda environment
RUN conda update -n base -c defaults conda && \
    conda create -n test python=3.12 && \
    conda activate test && \
    mamba env update -n test -f .github/environment-minimal.yml

# Install librosa with test dependencies
RUN conda activate test && \
    python -m pip install --upgrade-strategy only-if-needed -e .[tests]

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

ENTRYPOINT ["/bin/bash", "/workspace/run.sh"]