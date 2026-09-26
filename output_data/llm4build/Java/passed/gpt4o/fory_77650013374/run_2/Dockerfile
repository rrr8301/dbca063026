# Use a pre-built Python image with Python 3.8
FROM python:3.8-slim

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install JDK 8 (Temurin)
RUN wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u302-b08/OpenJDK8U-jdk_x64_linux_hotspot_8u302b08.tar.gz \
    && tar -xzf OpenJDK8U-jdk_x64_linux_hotspot_8u302b08.tar.gz -C /opt/ \
    && rm OpenJDK8U-jdk_x64_linux_hotspot_8u302b08.tar.gz
ENV JAVA_HOME=/opt/jdk8u302-b08
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Maven using a more reliable mirror
RUN wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz \
    && tar -xzf apache-maven-3.8.6-bin.tar.gz -C /opt/ \
    && rm apache-maven-3.8.6-bin.tar.gz
ENV MAVEN_HOME=/opt/apache-maven-3.8.6
ENV PATH="$MAVEN_HOME/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and set as entrypoint
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh
ENTRYPOINT ["/usr/local/bin/run.sh"]