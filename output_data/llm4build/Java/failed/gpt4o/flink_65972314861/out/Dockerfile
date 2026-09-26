FROM ubuntu:24.04

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    python3-dev \
    net-tools \
    zip \
    libapr1 \
    bc \
    openjdk-17-jdk \
    maven \
    python3.12-venv \
    python3-pip

# Create work directory
WORKDIR /root/flink

# Copy repository
COPY . .

# Install Python 3.12
RUN apt-get install -y python3.12

# Ensure the Maven wrapper is executable
RUN chmod +x ./mvnw

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Ensure test_controller.sh is executable
RUN chmod +x ./tools/ci/test_controller.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]