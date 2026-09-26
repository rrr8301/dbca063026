FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies and base tools
RUN apt-get update -yy && \
    apt-get install -yy \
        libsamplerate0 \
        wget \
        bzip2 \
        ca-certificates \
        git \
        build-essential \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/opt/miniconda/bin:$PATH"

# Initialize conda and accept terms of service
RUN conda init bash && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Create conda environment with Python 3.12 and dependencies from environment file
RUN conda create -n test -c conda-forge -c defaults \
        python=3.12 \
        pip \
        audioread \
        numpy \
        scipy \
        scikit-learn \
        joblib \
        decorator \
        numba \
        pysoundfile \
        pooch \
        packaging \
        soxr-python \
        msgpack-python \
        lazy_loader \
        typing_extensions \
        matplotlib \
        pytest-mpl \
        pytest-cov \
        pytest \
        coverage \
        ffmpeg \
        resampy && \
    conda run -n test pip install --upgrade pip setuptools samplerate

# Install librosa with test dependencies
RUN conda run -n test pip install --upgrade-strategy only-if-needed -e .[tests]

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
