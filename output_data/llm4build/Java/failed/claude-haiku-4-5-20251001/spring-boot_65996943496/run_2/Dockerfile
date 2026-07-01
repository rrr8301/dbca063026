FROM ubuntu:latest

# Set timezone to Pacific Time non-interactively
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install OS-level dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    unzip \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Java 25 (Liberica distribution) - Direct download approach
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/java \
    && cd /opt/java \
    && wget -q https://download.bell-sw.com/java/25/liberica-jdk-25-linux-x64.tar.gz \
    && tar -xzf liberica-jdk-25-linux-x64.tar.gz \
    && rm liberica-jdk-25-linux-x64.tar.gz \
    && ls -la /opt/java \
    && (mv jdk-25* liberica-java-25-full 2>/dev/null || mv jdk liberica-java-25-full 2>/dev/null || true) \
    && ls -la /opt/java

# Set JAVA_HOME
ENV JAVA_HOME=/opt/java/liberica-java-25-full
ENV PATH=$JAVA_HOME/bin:$PATH

# Verify Java installation
RUN java -version

# Create work directory
WORKDIR /workspace

# Copy repository
COPY . .

# Create Gradle properties directory
RUN mkdir -p $HOME/.gradle

# Configure Gradle properties
RUN echo 'systemProp.user.name=spring-builds+github' >> $HOME/.gradle/gradle.properties && \
    echo 'systemProp.org.gradle.internal.launcher.welcomeMessageEnabled=false' >> $HOME/.gradle/gradle.properties && \
    echo 'org.gradle.daemon=false' >> $HOME/.gradle/gradle.properties

# Copy and set run.sh as entrypoint
COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

ENTRYPOINT ["/workspace/run.sh"]