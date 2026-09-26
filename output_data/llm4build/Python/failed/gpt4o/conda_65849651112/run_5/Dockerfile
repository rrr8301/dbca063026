FROM ubuntu:22.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install necessary packages
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    ash \
    csh \
    fish \
    tcsh \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /miniconda.sh && \
    bash /miniconda.sh -b -p /opt/conda && \
    rm /miniconda.sh

ENV PATH="/opt/conda/bin:$PATH"

# Accept Terms of Service for Anaconda channels
RUN conda config --set channel_priority strict && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

# Create work directory
WORKDIR /app

# Copy repository contents
COPY . .

# Install Python dependencies using conda
RUN conda create --name test-env python=3.11 -y && \
    conda run -n test-env conda install --yes --file tests/requirements.txt && \
    conda run -n test-env conda install --yes --file tests/requirements-ci.txt && \
    conda run -n test-env conda install --yes --file tests/requirements-s3.txt

# Initialize shells
RUN conda init --all

# Copy run.sh and make it executable
COPY run.sh /app/run.sh
RUN chmod +x /app/run.sh

# Set entrypoint
ENTRYPOINT ["/app/run.sh"]