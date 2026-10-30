FROM ubuntu:latest

# Set timezone to Pacific Time
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set up JDK 17 (Zulu)
RUN wget -q https://cdn.azul.com/zulu/bin/zulu17.0.8-ca-jdk17.0.8-linux_x64.tar.gz -O /tmp/zulu17.tar.gz && \
    tar -xz -C /opt/ -f /tmp/zulu17.tar.gz && \
    rm /tmp/zulu17.tar.gz
ENV JAVA_HOME=/opt/zulu17.0.8-ca-jdk17.0.8-linux_x64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Set up Gradle
RUN wget https://services.gradle.org/distributions/gradle-7.6-bin.zip -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-7.6-bin.zip \
    && rm /tmp/gradle-7.6-bin.zip
ENV GRADLE_HOME=/opt/gradle/gradle-7.6
ENV PATH="$GRADLE_HOME/bin:$PATH"

# Create work directory
WORKDIR /app

# Copy repository
COPY . .

# Copy run.sh and make it executable
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/run.sh"]