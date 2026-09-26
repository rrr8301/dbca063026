FROM ubuntu:24.04

# Set timezone to Pacific Time (noninteractive)
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install miniforge (conda-forge only, no defaults)
RUN curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/miniforge && \
    rm /tmp/miniforge.sh

ENV PATH="/opt/miniforge/bin:$PATH"
ENV CONDA_AUTO_UPDATE_CONDA=false

# Configure conda to use only conda-forge and remove defaults
RUN conda config --remove-key channels && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda config --set solver libmamba && \
    conda config --set auto_update_conda false && \
    conda config --set show_channel_urls true && \
    conda clean --all -y

# Set environment variables
ENV OMP_NUM_THREADS=10
ENV MKL_THREADING_LAYER=GNU

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace/

# Copy run script
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]