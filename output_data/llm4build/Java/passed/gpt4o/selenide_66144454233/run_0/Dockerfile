FROM ubuntu:22.04

# Set timezone and locale
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Set environment variables for CI
ENV CI=true
ENV GITHUB_ACTIONS=true

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Install Java JDK 17
RUN apt-get update && apt-get install -y openjdk-17-jdk && rm -rf /var/lib/apt/lists/*

# Install Gradle
RUN wget https://services.gradle.org/distributions/gradle-7.5-bin.zip -P /tmp \
    && unzip -d /opt/gradle /tmp/gradle-7.5-bin.zip \
    && ln -s /opt/gradle/gradle-7.5/bin/gradle /usr/bin/gradle

# Create a non-root user
RUN useradd -m testuser
WORKDIR /workspace
RUN chown -R testuser /workspace
USER testuser

# Copy the repository
COPY . /workspace

# Configure git
RUN git config --global --add safe.directory '*'