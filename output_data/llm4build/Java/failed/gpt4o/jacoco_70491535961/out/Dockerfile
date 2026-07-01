FROM ubuntu:24.04

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
    software-properties-common \
    && apt-get clean

# Install Maven 3.9.12
RUN wget -q https://archive.apache.org/dist/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz -O maven.tar.gz && \
    tar xzf maven.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.12 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm maven.tar.gz

# Install Zulu JDK 17
RUN wget -q https://cdn.azul.com/zulu/bin/zulu17.44.15-ca-jdk17.0.8-linux_amd64.deb -O zulu-jdk.deb && \
    apt-get update && apt-get install -y ./zulu-jdk.deb && \
    rm zulu-jdk.deb

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]