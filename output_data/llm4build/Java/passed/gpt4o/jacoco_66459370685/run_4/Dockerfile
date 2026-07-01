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
    && rm -rf /var/lib/apt/lists/*

# Install Zulu JDK 18
RUN wget -qO zulu.tar.gz https://cdn.azul.com/zulu/bin/zulu18.0.0.0-ca-jdk18.0.0-linux_x64.tar.gz || \
    wget -qO zulu.tar.gz https://cdn.azul.com/zulu/bin/zulu18.0.0.0-ca-jdk18.0.0-linux_x64.tar.gz && \
    tar -xzvf zulu.tar.gz -C /opt/ && \
    ln -s /opt/zulu18.0.0.0-ca-jdk18.0.0-linux_x64/bin/* /usr/local/bin/ && \
    rm zulu.tar.gz

# Install Maven
RUN wget -qO- https://www-us.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz | tar -xz -C /opt/ && \
    ln -s /opt/apache-maven-3.8.6/bin/mvn /usr/local/bin/mvn

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