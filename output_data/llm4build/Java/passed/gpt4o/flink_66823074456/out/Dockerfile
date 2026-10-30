FROM chesnay/flink-ci:java_8_11_17_21_maven_386_jammy

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    python3-dev \
    curl \
    wget \
    net-tools \
    zip \
    bc \
    libapr1

# Create work directory
WORKDIR /root/flink

# Copy repository contents
COPY . .

# Ensure necessary scripts are executable
RUN chmod +x ./mvnw \
    && chmod +x ./tools/azure-pipelines/unpack_build_artifact.sh \
    && chmod +x ./tools/azure-pipelines/uploading_watchdog.sh

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]