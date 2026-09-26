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
    && rm -rf /var/lib/apt/lists/*

# Install Zulu OpenJDK 17
RUN wget -q https://cdn.azul.com/zulu/bin/zulu17.44.15-ca-jdk17.0.8-linux_amd64.deb -O zulu17.deb && \
    apt-get update && apt-get install -y ./zulu17.deb && \
    rm zulu17.deb

# Install Maven 3.9.12
RUN wget -qO- https://archive.apache.org/dist/maven/maven-3/3.9.12/binaries/apache-maven-3.9.12-bin.tar.gz | tar xz -C /opt && \
    ln -s /opt/apache-maven-3.9.12/bin/mvn /usr/bin/mvn

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