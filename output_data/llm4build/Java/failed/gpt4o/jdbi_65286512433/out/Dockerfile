FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=UTC
RUN apt-get update && apt-get install -y tzdata && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && dpkg-reconfigure --frontend noninteractive tzdata
ENV LANG=C.UTF-8

# Set environment variables
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    make \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Temurin JDK 17
RUN wget -qO- https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    add-apt-repository --yes https://packages.adoptium.net/artifactory/deb/ && \
    apt-get update && apt-get install -y temurin-17-jdk

# Install Maven 3.9.0
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz && \
    tar xzvf apache-maven-3.9.0-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.0/bin/mvn /usr/bin/mvn && \
    rm apache-maven-3.9.0-bin.tar.gz

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

# Create non-root user and switch to it
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set entrypoint
ENTRYPOINT ["/workspace/run.sh"]