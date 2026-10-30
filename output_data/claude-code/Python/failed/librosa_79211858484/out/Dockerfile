FROM continuumio/miniconda3:latest

ENV DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/conda/bin:$PATH"

# Install system dependencies
RUN apt-get update -yy && \
    apt-get install -yy libsamplerate0 curl git build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create conda environment with the test dependencies
WORKDIR /tmp/setup
COPY repo/.github/environment-ci.yml ./environment.yml
RUN conda env create -n test -f environment.yml && \
    conda clean -afy

# Copy repository
WORKDIR /app
COPY repo/ .

# Install librosa in development mode
RUN bash -c "source activate test && python -m pip install --upgrade-strategy only-if-needed -e .[tests]"

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
