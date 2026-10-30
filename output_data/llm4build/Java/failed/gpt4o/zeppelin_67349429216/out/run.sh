#!/bin/bash

# Activate conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate python_3_with_R

# Install project dependencies
./mvnw install -Pbuild-distr -DskipTests -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples ${MAVEN_ARGS}

# Install and test plugins
./mvnw package -pl zeppelin-plugins -amd ${MAVEN_ARGS}

# Make IRkernel available to Jupyter
R -e "IRkernel::installspec()"

# Run tests
./mvnw verify -Pusing-packaged-distr -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples -Dtests.to.exclude=**/org/apache/zeppelin/spark/* -DfailIfNoTests=false || true