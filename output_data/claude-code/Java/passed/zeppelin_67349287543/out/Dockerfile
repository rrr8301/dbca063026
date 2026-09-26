FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
ENV MAVEN_OPTS="-Xms1024M -Xmx2048M -XX:MaxMetaspaceSize=1024m -XX:-UseGCOverheadLimit -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.count=3"
ENV MAVEN_ARGS="-B --no-transfer-progress"
ENV ZEPPELIN_HELIUM_REGISTRY=helium
ENV SPARK_PRINT_LAUNCH_COMMAND="true"
ENV SPARK_LOCAL_IP=127.0.0.1
ENV ZEPPELIN_LOCAL_IP=127.0.0.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 11 and Maven
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install conda/miniconda
RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* && \
    wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH=/opt/conda/bin:$PATH

# Install R and dependencies
RUN apt-get update && apt-get install -y \
    r-base \
    r-base-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up conda channels and create environment
RUN conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda config --set auto_update_conda false && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

# Create conda environment with Python 3.9 and R
RUN conda create -y -n python_3_with_R \
    python=3.9 \
    pycodestyle \
    scipy \
    'numpy=1.19.5' \
    grpcio \
    protobuf \
    pandasql \
    'sqlalchemy=1.4.46' \
    ipython \
    ipython_genutils \
    ipykernel \
    'jupyter_client=5' \
    hvplot \
    'holoviews=1.16' \
    plotnine \
    seaborn \
    intake \
    intake-parquet \
    intake-xarray \
    altair \
    vega_datasets \
    plotly \
    'jinja2=3.0.3' \
    pip \
    'r-base=3.6' \
    r-data.table \
    r-evaluate \
    r-base64enc \
    r-knitr \
    r-ggplot2 \
    r-irkernel \
    r-shiny \
    r-googlevis

# Copy repo into container
COPY repo/ /app/
WORKDIR /app

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
