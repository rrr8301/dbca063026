#!/bin/bash

# Activate conda
source /opt/conda/etc/profile.d/conda.sh

# Setup conda environment
conda env create -f testing/env_python_3.9_with_R.yml
conda activate python_3_with_R

# Make IRkernel available to Jupyter
R -e "IRkernel::installspec()"

# Install application with Maven
./mvnw install -Pbuild-distr -DskipTests -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples ${MAVEN_ARGS}

# Install and test plugins
./mvnw package -pl zeppelin-plugins -amd ${MAVEN_ARGS}

# Run tests
./mvnw verify -Pusing-packaged-distr -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples -Dtests.to.exclude=**/org/apache/zeppelin/spark/* -DfailIfNoTests=false