FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y \
    git wget gpg kmod cmake make swig \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh
ENV PATH="/opt/conda/bin:$PATH"

# Accept Anaconda Terms of Service
RUN conda config --set channel_priority strict && \
    conda config --add channels conda-forge && \
    conda config --set auto_update_conda false && \
    conda config --set always_yes yes && \
    conda config --set quiet true && \
    conda config --set show_channel_urls true && \
    conda install -c conda-forge conda-libmamba-solver && \
    conda config --set solver libmamba && \
    conda install -c defaults anaconda-client && \
    anaconda-client --accept-tos

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Install conda dependencies
RUN conda install -y -c conda-forge python=3.12 cmake=3.30.4 make=4.2 swig=4.0 numpy scipy pytest gflags setuptools

# Copy run.sh and set as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh
ENTRYPOINT ["/workspace/run.sh"]