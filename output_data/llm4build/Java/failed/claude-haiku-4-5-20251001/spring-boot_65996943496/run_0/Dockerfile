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

# Install Java 25 (Liberica distribution)
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    && add-apt-repository ppa:bellsoft/liberica \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    liberica-java-25-full \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/liberica-java-25-full
ENV PATH=$JAVA_HOME/bin:$PATH

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