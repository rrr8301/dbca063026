#!/bin/bash
set -e

# Activate conda base environment
source /opt/conda/etc/profile.d/conda.sh
conda activate base

# Tune Runner VM: Add hosts entry for hostname resolution
CURRENT_IP=$(hostname -I | awk '{print $1}')
HOSTNAME_FQDN=$(hostname -f)
HOSTNAME_SHORT=$(hostname -s)
echo -e "${CURRENT_IP}\t${HOSTNAME_FQDN} ${HOSTNAME_SHORT}" | sudo tee -a /etc/hosts > /dev/null

# Set Maven options and args
export MAVEN_OPTS="-Xms1024M -Xmx2048M -XX:MaxMetaspaceSize=1024m -XX:-UseGCOverheadLimit -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.count=3"
export MAVEN_ARGS="-B --no-transfer-progress"
export ZEPPELIN_HELIUM_REGISTRY="helium"
export SPARK_PRINT_LAUNCH_COMMAND="true"
export SPARK_LOCAL_IP="127.0.0.1"
export ZEPPELIN_LOCAL_IP="127.0.0.1"

# Step 1: Install application with some interpreter
echo "=== Installing application with interpreters ==="
mvn install -Pbuild-distr -DskipTests -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples ${MAVEN_ARGS} -Drat.skip=true -Dlicense.skip=true

# Step 2: Install and test plugins
echo "=== Installing and testing plugins ==="
mvn package -pl zeppelin-plugins -amd ${MAVEN_ARGS} -Drat.skip=true -Dlicense.skip=true

# Step 3: Setup conda environment with Python 3.9 and R
echo "=== Setting up conda environment with Python 3.9 and R ==="
if [ -f "testing/env_python_3.9_with_R.yml" ]; then
    mamba env create -f testing/env_python_3.9_with_R.yml -n python_3_with_R
    conda activate python_3_with_R
else
    echo "Warning: testing/env_python_3.9_with_R.yml not found, skipping conda environment setup"
fi

# Step 4: Make IRkernel available to Jupyter
echo "=== Making IRkernel available to Jupyter ==="
R -e "IRkernel::installspec()" || echo "Warning: IRkernel installation failed, continuing..."
conda list
conda info

# Step 5: Run tests
echo "=== Running tests ==="
mvn verify -Pusing-packaged-distr -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples -Dtests.to.exclude=**/org/apache/zeppelin/spark/* -DfailIfNoTests=false ${MAVEN_ARGS} -Drat.skip=true -Dlicense.skip=true

echo "=== All tests completed ==="