FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
RUN echo "UTC" > /etc/timezone && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -y --no-install-recommends tzdata && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

ENV CI=true
ENV GITHUB_ACTIONS=true
ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install OpenJDK 17
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jdk && \
    rm -rf /var/lib/apt/lists/*

# Install Maven (updated version)
RUN wget https://downloads.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz && \
    tar xzvf apache-maven-3.9.4-bin.tar.gz -C /opt && \
    ln -s /opt/apache-maven-3.9.4 /opt/maven && \
    ln -s /opt/maven/bin/mvn /usr/bin/mvn && \
    rm apache-maven-3.9.4-bin.tar.gz

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Create non-root user
RUN useradd -m testuser && chown -R testuser /workspace
USER testuser

# Set run.sh as entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]