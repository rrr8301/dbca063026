FROM ubuntu:22.04

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

# Install Temurin JDK 17
RUN wget https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.8+7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_7.tar.gz \
    && tar -xzf OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_7.tar.gz -C /opt/ \
    && rm OpenJDK17U-jdk_x64_linux_hotspot_17.0.8_7.tar.gz
ENV JAVA_HOME=/opt/jdk-17.0.8+7
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Maven
RUN wget https://www.apache.org/dyn/closer.cgi?action=download&filename=maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.tar.gz \
    && tar -xzf apache-maven-3.8.8-bin.tar.gz -C /opt/ \
    && rm apache-maven-3.8.8-bin.tar.gz
ENV MAVEN_HOME=/opt/apache-maven-3.8.8
ENV PATH="$MAVEN_HOME/bin:$PATH"

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-7.6-bin.zip \
    && unzip gradle-7.6-bin.zip -d /opt/ \
    && rm gradle-7.6-bin.zip
ENV GRADLE_HOME=/opt/gradle-7.6
ENV PATH="$GRADLE_HOME/bin:$PATH"

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