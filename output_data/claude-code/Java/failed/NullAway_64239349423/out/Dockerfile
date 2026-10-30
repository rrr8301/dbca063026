FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    ca-certificates \
    gnupg \
    build-essential \
    shellcheck \
    openjdk-11-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

# Create JDK install directory
RUN mkdir -p /opt/jdk

# Download and install JDK 27 EA from jdk.java.net
RUN cd /tmp && \
    wget -q https://download.java.net/java/early_access/jdk27/22/GPL/openjdk-27-ea+22_linux-x64_bin.tar.gz && \
    tar -xzf openjdk-27-ea+22_linux-x64_bin.tar.gz && \
    mv jdk-27 /opt/jdk/jdk-27 && \
    rm openjdk-27-ea+22_linux-x64_bin.tar.gz

# Install temurin JDKs using apt
RUN apt-get update && \
    apt-get install -y \
    wget \
    apt-transport-https \
    gpg \
    && rm -rf /var/lib/apt/lists/*

# Add Eclipse Temurin GPG key and repository
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - && \
    echo "deb https://packages.adoptium.net/artifactory/deb jammy main" > /etc/apt/sources.list.d/adoptium.list

# Install temurin JDKs
RUN apt-get update && apt-get install -y \
    temurin-17-jdk \
    temurin-21-jdk \
    temurin-25-jdk \
    && rm -rf /var/lib/apt/lists/*

# Set up environment for multiple JDKs
ENV JAVA_HOME=/usr/lib/jvm/temurin-25-jdk-amd64
ENV PATH=/opt/jdk/jdk-27/bin:$JAVA_HOME/bin:$PATH

# Create a symbolic link for JDK 27 for toolchain detection
RUN ln -s /opt/jdk/jdk-27 /usr/lib/jvm/jdk-27

# Install Android SDK
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    cd /tmp && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip && \
    unzip -q commandlinetools-linux-11076708_latest.zip && \
    mv cmdline-tools $ANDROID_HOME/cmdline-tools/latest && \
    rm commandlinetools-linux-11076708_latest.zip

# Install Android SDK for API 30
RUN yes | sdkmanager "platforms;android-30" "build-tools;30.0.3" --sdk_root=$ANDROID_HOME || true

WORKDIR /app

# Copy the repository
COPY repo/ /app/

# Make gradlew executable
RUN chmod +x /app/gradlew

# Copy and make run.sh executable
COPY run.sh /run.sh
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
