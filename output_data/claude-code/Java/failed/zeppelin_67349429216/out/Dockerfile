FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    maven \
    git \
    curl \
    wget \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda (alternative to conda)
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

ENV PATH /opt/conda/bin:$PATH

# Setup Maven environment variables
ENV MAVEN_OPTS="-Xms1024M -Xmx2048M -XX:MaxMetaspaceSize=1024m -XX:-UseGCOverheadLimit -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.count=3"
ENV MAVEN_ARGS="-B --no-transfer-progress"
ENV ZEPPELIN_HELIUM_REGISTRY="helium"
ENV SPARK_PRINT_LAUNCH_COMMAND="true"
ENV SPARK_LOCAL_IP="127.0.0.1"
ENV ZEPPELIN_LOCAL_IP="127.0.0.1"

WORKDIR /app

COPY repo/ /app/

# Copy conda environment file
COPY repo/testing/env_python_3.9_with_R.yml /tmp/env.yml

# Setup conda environment with python 3.9 and R
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r && \
    conda env create -f /tmp/env.yml

# Activate the conda environment
RUN echo "source activate python_3_with_R" > ~/.bashrc

# Make IRkernel available to Jupyter
RUN /bin/bash -c "source activate python_3_with_R && R -e 'IRkernel::installspec()'"

COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
