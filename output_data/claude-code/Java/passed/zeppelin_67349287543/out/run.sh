#!/usr/bin/env bash

set -e

# Activate conda environment
source /opt/conda/etc/profile.d/conda.sh
conda activate python_3_with_R

cd /app

# Set environment variables
export MAVEN_OPTS="-Xms1024M -Xmx2048M -XX:MaxMetaspaceSize=1024m -XX:-UseGCOverheadLimit -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.count=3"
export MAVEN_ARGS="-B --no-transfer-progress"
export ZEPPELIN_HELIUM_REGISTRY=helium
export SPARK_PRINT_LAUNCH_COMMAND="true"
export SPARK_LOCAL_IP=127.0.0.1
export ZEPPELIN_LOCAL_IP=127.0.0.1

echo "======= Installing application with some interpreter ======="
./mvnw install -Pbuild-distr -DskipTests -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples ${MAVEN_ARGS}

echo "======= Installing and testing plugins ======="
./mvnw package -pl zeppelin-plugins -amd ${MAVEN_ARGS}

echo "======= Making IRkernel available to Jupyter ======="
R -e "IRkernel::installspec()"
conda list
conda info

echo "======= Running tests ======="
./mvnw verify -Pusing-packaged-distr -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples -Dtests.to.exclude=**/org/apache/zeppelin/spark/* -DfailIfNoTests=false

echo "FINAL_STATUS = SUCCESS"
