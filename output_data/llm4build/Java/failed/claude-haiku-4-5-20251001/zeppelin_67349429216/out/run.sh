#!/bin/bash

set -e

# Enable error handling: continue on test failures but track them
TEST_FAILED=0

# Tune Runner VM: Add hostname to /etc/hosts for proper reverse lookups
echo "Tuning VM configuration..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Get the current IP address and hostname
    IP_ADDR=$(hostname -I | awk '{print $1}')
    HOSTNAME_FULL=$(hostname -f)
    HOSTNAME_SHORT=$(hostname -s)
    
    # Add to /etc/hosts if not already present
    if ! grep -q "$HOSTNAME_FULL" /etc/hosts; then
        echo -e "${IP_ADDR}\t${HOSTNAME_FULL} ${HOSTNAME_SHORT}" | sudo tee -a /etc/hosts
    fi
fi

# Set Maven environment variables
export MAVEN_OPTS="-Xms1024M -Xmx2048M -XX:MaxMetaspaceSize=1024m -XX:-UseGCOverheadLimit -Dhttp.keepAlive=false -Dmaven.wagon.http.pool=false -Dmaven.wagon.http.retryHandler.count=3"
export MAVEN_ARGS="-B --no-transfer-progress"
export ZEPPELIN_HELIUM_REGISTRY="helium"
export SPARK_PRINT_LAUNCH_COMMAND="true"
export SPARK_LOCAL_IP="127.0.0.1"
export ZEPPELIN_LOCAL_IP="127.0.0.1"

# Initialize conda shell
source /opt/miniconda/etc/profile.d/conda.sh

echo "Building and installing application with interpreters..."
./mvnw install -Pbuild-distr -DskipTests -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples ${MAVEN_ARGS} || {
    echo "ERROR: Maven install failed"
    TEST_FAILED=1
}

echo "Installing and testing plugins..."
./mvnw package -pl zeppelin-plugins -amd ${MAVEN_ARGS} || {
    echo "ERROR: Maven package for plugins failed"
    TEST_FAILED=1
}

echo "Setting up conda environment with Python 3.9 and R..."
if [ -f "testing/env_python_3.9_with_R.yml" ]; then
    conda env create -f testing/env_python_3.9_with_R.yml -n python_3_with_R || {
        echo "WARNING: Conda environment creation had issues, attempting to continue"
    }
    conda activate python_3_with_R
else
    echo "WARNING: Conda environment file not found at testing/env_python_3.9_with_R.yml"
    echo "Creating minimal Python 3.9 environment..."
    conda create -y -n python_3_with_R python=3.9 r-base || {
        echo "WARNING: Minimal conda environment creation had issues"
    }
    conda activate python_3_with_R
fi

echo "Listing conda packages..."
conda list || true
conda info || true

echo "Installing IRkernel for R..."
R -e "IRkernel::installspec()" || {
    echo "WARNING: IRkernel installation had issues, continuing with tests"
}

echo "Running tests..."
./mvnw verify -Pusing-packaged-distr -pl zeppelin-server,zeppelin-web,spark-submit,spark/scala-2.12,spark/scala-2.13,markdown,angular,shell -am -Pweb-classic -Phelium-dev -Pexamples -Dtests.to.exclude=**/org/apache/zeppelin/spark/* -DfailIfNoTests=false ${MAVEN_ARGS} || {
    echo "ERROR: Maven verify (tests) failed"
    TEST_FAILED=1
}

echo "Test execution completed"

# Exit with failure code if any step failed
if [ $TEST_FAILED -ne 0 ]; then
    echo "Some steps failed during execution"
    exit 1
fi

exit 0